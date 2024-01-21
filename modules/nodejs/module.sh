[[ "${DFLOADED[NODEJS]}" == "1" ]] && return
DFLOADED[NODEJS]="1"

df_package "nodejs"

npmOut="$DOTFILESDIR/modules/nodejs/out/npmrc"
mkdir -p "$(dirname "$npmOut")"
create_empty_file "$npmOut"

cat "$DOTFILESDIR/modules/nodejs/npmrc" >> "$npmOut"
mkdir -p "$XDG_CONFIG_HOME/npm"

if [[ "${DFCONF[IS_WORK]}" == "1" ]]; then
  echo "//pkgs.dev.azure.com/SynergiPartners/_packaging/Synergi/npm/registry/:username=SynergiPartners" >> "$npmOut"
  echo "//pkgs.dev.azure.com/SynergiPartners/_packaging/Synergi/npm/registry/:_password=\${SYNERGI_ARTIFACTS_PAT_BASE64}" >> "$npmOut"
  echo "//pkgs.dev.azure.com/SynergiPartners/_packaging/Synergi/npm/registry/:email=wdixon@synergipartners.com" >> "$npmOut"
fi

chmod -w "$npmOut"
df_symlink "$npmOut" "$XDG_CONFIG_HOME/npm/npmrc"
