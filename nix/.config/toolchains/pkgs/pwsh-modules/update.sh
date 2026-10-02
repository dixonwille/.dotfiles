#!/usr/bin/env bash
# Regenerates lock.json from modules.json: each listed module, plus the modules
# it depends on, at the version modules.json's Az release ships it (so they
# work together), with the PowerShell Gallery's own SHA-512 of each package.
# Nothing is downloaded but the Gallery's metadata.
#   ./update.sh           lock at modules.json's Az release
#   ./update.sh --latest  move modules.json to the newest Az release first
# Then `nix profile upgrade --all` installs the new versions.
set -euo pipefail
cd "$(dirname "$0")"

api=https://www.powershellgallery.com/api/v2

# A package's dependencies ("Name:[range]:|..."), hash and hash algorithm, as JSON
properties() {
  curl -fsSL "$api/Packages(Id='$1',Version='$2')" |
    yq -p xml -o json '.entry."m:properties" | {
      "deps": (."d:Dependencies" | select(tag == "!!str") // ""),
      "hash": ."d:PackageHash",
      "alg": ."d:PackageHashAlgorithm"
    }'
}

if [[ ${1:-} == --latest ]]; then
  latest=$(curl -fsSL "$api/Packages()?\$filter=Id%20eq%20'Az'%20and%20IsLatestVersion" |
    yq -p xml '.feed.entry."m:properties"."d:Version"')
  jq --arg v "$latest" '.Az = $v' modules.json >modules.json.tmp
  mv modules.json.tmp modules.json
fi

# The version of each module in the Az release: the lower bound of Az's
# dependency range ("[5.5.3, )" or "[2.0.1, 2.0.1]")
az=$(jq -r .Az modules.json)
declare -A versions
while IFS=: read -r name range _; do
  [[ -n $name ]] || continue
  version=${range#[}
  version=${version%%,*}
  versions[$name]=${version%]}
done < <(properties Az "$az" | jq -r .deps | tr '|' '\n')

mapfile -t queue < <(jq -r '.modules[]' modules.json)
declare -A locked
entries=()
while ((${#queue[@]})); do
  name=${queue[0]}
  queue=("${queue[@]:1}")
  [[ -z ${locked[$name]:-} ]] || continue
  version=${versions[$name]:-}
  if [[ -z $version ]]; then
    echo "$name isn't part of Az $az" >&2
    exit 1
  fi
  props=$(properties "$name" "$version")
  if [[ $(jq -r .alg <<<"$props") != SHA512 ]]; then
    echo "$name $version: expected a SHA512 package hash" >&2
    exit 1
  fi
  locked[$name]=1
  entries+=("$(jq -c --arg n "$name" --arg v "$version" '{name: $n, version: $v, hash: ("sha512-" + .hash)}' <<<"$props")")
  while IFS=: read -r dep _; do
    [[ -z $dep ]] || queue+=("$dep")
  done < <(jq -r .deps <<<"$props" | tr '|' '\n')
done

printf '%s\n' "${entries[@]}" | jq -s 'sort_by(.name)' >lock.json
echo "Locked ${#entries[@]} modules from Az $az"
