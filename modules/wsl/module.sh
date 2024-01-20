[[ "${DFCONF[IS_WSL]}" != "1" ]] && return
[[ "${DFLOADED[WSL]}" == "1" ]] && return
DFLOADED[WSL]="1"

df_symlink "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/Desktop" "$HOME/Desktop"
df_symlink "/mnt/c/Users/${DFCONF[WINDOWS_USER]}/Downloads" "$HOME/Downloads"

# BUG: https://github.com/wslutilities/wslu/issues/298
# df_package wslutilities/wslu
# df_pacakge wslu
df_after_install "sudo dnf install wslu --repofrompath 'wslu38,https://download.copr.fedorainfracloud.org/results/wslutilities/wslu/fedora-38-\$basearch/' --setopt='wslu38.gpgkey=https://download.copr.fedorainfracloud.org/results/wslutilities/wslu/pubkey.gpg' -y"
