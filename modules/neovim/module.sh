[[ "${DFLOADED[NEOVIM]}" == "1" ]] && return
DFLOADED[NEOVIM]="1"

load_module "nodejs"
load_module "go"
load_module "rust"

df_package "neovim"
df_package "make"
df_package "gcc"
df_package "g++"
df_package "wl-clipboard"

if [[ ! -e "$XDG_CONFIG_HOME/nvim" ]]; then
  df_symlink "$DOTFILESDIR/modules/neovim/rc" "$XDG_CONFIG_HOME/nvim"
fi
