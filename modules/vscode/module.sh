[[ "${DFLOADED[VSCODE]}" == "1" ]] && return
DFLOADED[VSCODE]="1"

envOut="$DOTFILESDIR/modules/vscode/out/environment"
mkdir -p "$(dirname "$envOut")"
create_empty_file "$envOut"

if [[ -n "${DFCONF[WINDOWS_USER]}" ]]; then
	echo "export PATH=\"/mnt/c/Users/${DFCONF[WINDOWS_USER]}/AppData/Local/Programs/Microsoft VS Code/bin:$PATH\"" >"$envOut"
fi

chmod -w "$envOut"
