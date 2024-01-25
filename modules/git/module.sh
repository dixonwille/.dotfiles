[[ "${DFLOADED[GIT]}" == "1" ]] && return
DFLOADED[GIT]="1"

df_package "git"
df_package "git-delta"

gitOut="$DOTFILESDIR/modules/git/out/config"
mkdir -p "$(dirname "$gitOut")"
create_empty_file "$gitOut"

cat "$DOTFILESDIR/modules/git/config" >> "$gitOut"
mkdir -p "$XDG_CONFIG_HOME/git"

if [[ "${DFCONF[IS_WSL]}" == "1" ]] && [[ -n "${DFCONF[WINDOWS_USER]}" ]];then
	wslOut="$(dirname "$gitOut")/wsl"
  create_empty_file "$wslOut"

cat << EOF > "$wslOut"
[core]
	sshCommand = "/mnt/c/Windows/System32/OpenSSH/ssh.exe"

[gpg "ssh"]
	program = "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/AppData/Local/1Password/app/8/op-ssh-sign.exe"
EOF

	chmod -w "$wslOut"
	df_symlink "$wslOut" "$XDG_CONFIG_HOME/git/wsl"
	echo "[include]" >> "$gitOut"
	echo "	path = \"$XDG_CONFIG_HOME/git/wsl\"" >> "$gitOut"
else
	df_package "openssh-clients"
fi

if [[ "${DFCONF[IS_WORK]}" == "1" ]]; then
	df_symlink "$DOTFILESDIR/modules/git/synergi" "$XDG_CONFIG_HOME/git/synergi"
	echo "[includeIf \"gitdir:~/projects/synergi/\"]" >> "$gitOut"
	echo "	path = \"$XDG_CONFIG_HOME/git/synergi\"" >> "$gitOut"
fi

chmod -w "$gitOut"
df_symlink "$gitOut" "$XDG_CONFIG_HOME/git/config"
