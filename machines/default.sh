[[ -z "${DFCONF[IS_WORK]}" ]] && DFCONF[IS_WORK]="0"
[[ "${DFCONF[IS_WSL]}" == "1" ]] && DFCONF[WINDOWS_USER]="wdixon"

df_module "1password"
df_module "wsl"
df_module "zsh"
df_module "git"
df_module "neovim"
df_module "vscode"
df_package "jq"

if [[ "${DFCONF[IS_FEDORA]}" == "1" ]]; then
	df_package "which"
	df_package "ncurses"
	df_package "iputils"
	df_package "bind-utils"
	df_package "iproute"
	df_package "man"
	df_package "xz"
fi
