[[ "${DFCONF[IS_WSL]}" != "1" ]] && return
[[ "${DFLOADED[WSL]}" == "1" ]] && return
DFLOADED[WSL]="1"

if [[ ! -e "$HOME/Desktop" ]]; then
	df_symlink "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/Desktop" "$HOME/Desktop"
fi
if [[ ! -e "$HOME/Downloads" ]]; then
	df_symlink "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/Downloads" "$HOME/Downloads"
fi

envFile="$DOTFILESDIR/modules/wsl/out/environment"
mkdir -p "$(dirname "$envFile")"
create_empty_file "$envFile"
cat "$DOTFILESDIR/modules/wsl/baseenv" >>"$envFile"

if [[ "${DFCONF[IS_WORK]}" == "1" ]]; then
	if [[ ! -e "$HOME/projects/synergi/Documentation" ]]; then
		df_symlink "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/projects/synergi/Documentation" "$HOME/projects/synergi/Documentation"
	fi
	echo "export SY_PROJECTS_DIR=\"$HOME/projects/synergi\"" >>"$envFile"
	echo "export SY_DOCUMENTATION_REPOSITORY=\"\$SY_PROJECTS_DIR/Documentation\"" >>"$envFile"
fi

chmod -w "$envFile"

df_package "wslutilities/wslu"
df_package "wslu"
