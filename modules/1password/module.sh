[[ "${DFLOADED[ONEPASSWORD]}" == "1" ]] && return
DFLOADED[ONEPASSWORD]="1"

add_pass_account() {
  if [[ "$(op account list | grep "^$1\\s")" == "" ]]; then
    op account add --address "$2" --email "$3" --shorthand "$1"
  fi
}

secOut="$DOTFILESDIR/modules/1password/out/secrets"
envOut="$DOTFILESDIR/modules/1password/out/environment"
mkdir -p "$(dirname "$secOut")"
create_empty_file "$secOut"
create_empty_file "$envOut"

add_pass_account "my" "my.1password.com" "dixonwille@gmail.com"
echo "export OP_ACCOUNT=my.1password.com" > "$envOut"
# Uncomment when/if default has secrets
# cat "$DOTFILESDIR/modules/1password/default.env" | op inject --account "my" >> "$secOut"

if [[ "${DFCONF[IS_WORK]}" == "1" ]]; then
  add_pass_account "sypa" "synergipartners.1password.com" "wdixon@synergipartners.com"
  echo "export OP_ACCOUNT=synergipartners.1password.com" > "$envOut"
  cat "$DOTFILESDIR/modules/1password/synergi.env" | op inject --account "sypa" >> "$secOut"
fi

chmod -w "$secOut"
chmod -w "$envOut"
df_symlink "$secOut" "$XDG_CONFIG_HOME/environment.d/99-secrets"
