#!/usr/bin/env bash
# Moves npm-server.nix's language servers to their newest npm release: pins the
# version in each directory's package.json and regenerates its package-lock.json.
# Nothing is installed; npm comes from this flake's nixpkgs, so it needn't be on
# PATH.
#   ./update.sh                          every server here
#   ./update.sh actions-languageserver   just the ones named
# Then `nix profile upgrade --all` (or direnv reload) installs the new versions.
set -euo pipefail
cd "$(dirname "$0")"
flake=$(cd ../.. && pwd)

npm() {
  nix shell --inputs-from "$flake" nixpkgs#nodejs_24 -c npm "$@"
}

if (($#)); then
  dirs=("$@")
else
  dirs=(*/package.json)
  dirs=("${dirs[@]%/package.json}")
fi

for dir in "${dirs[@]}"; do
  # Each package.json depends on just the one server
  package=$(jq -r '.dependencies | keys[0]' "$dir/package.json")
  old=$(jq -r --arg p "$package" '.dependencies[$p]' "$dir/package.json")
  (cd "$dir" && npm install --package-lock-only --ignore-scripts --save-exact "$package@latest" >/dev/null)
  new=$(jq -r --arg p "$package" '.dependencies[$p]' "$dir/package.json")
  if [[ $old == "$new" ]]; then
    echo "$package $new (unchanged)"
  else
    echo "$package $old -> $new"
  fi
done
