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
cat "$DOTFILESDIR/modules/wsl/baseenv" >> "$envFile"

if [[ "${DFCONF[IS_WORK]}" == "1" ]]; then
  if [[ ! -e "$HOME/projects/synergi/Documentation" ]]; then
    df_symlink "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/projects/synergi/Documentation" "$HOME/projects/synergi/Documentation"
  fi
  echo "export SY_PROJECTS_DIR=\"$HOME/projects/synergi\"" >> "$envFile"
  echo "export SY_DOCUMENTATION_REPOSITORY=\"\$SY_PROJECTS_DIR/Documentation\"" >> "$envFile"
fi

chmod -w "$envFile"

# BUG: https://github.com/wslutilities/wslu/issues/298
# df_package wslutilities/wslu
# df_pacakge wslu
df_after_install "sudo dnf install wslu --repofrompath 'wslu38,https://download.copr.fedorainfracloud.org/results/wslutilities/wslu/fedora-38-\$basearch/' --setopt='wslu38.gpgkey=https://download.copr.fedorainfracloud.org/results/wslutilities/wslu/pubkey.gpg' -y"
