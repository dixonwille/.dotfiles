[[ "${DFLOADED[ZSH]}" == "1" ]] && return
DFLOADED[ZSH]="1"

load_module "git"

mkdir -p "$XDG_CONFIG_HOME/zsh"
mkdir -p "$XDG_CONFIG_HOME/oh-my-posh"
mkdir -p "$XDG_CONFIG_HOME/environment.d"
mkdir -p "$XDG_CONFIG_HOME/alias.d"
mkdir -p "$XDG_CACHE_HOME/zsh"

df_symlink "$DOTFILESDIR/modules/zsh/.zshenv" "$XDG_CONFIG_HOME/zsh/.zshenv"
df_symlink "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"
df_symlink "$DOTFILESDIR/modules/zsh/.zshrc" "$XDG_CONFIG_HOME/zsh/.zshrc"
df_symlink "$DOTFILESDIR/modules/zsh/.zprofile" "$XDG_CONFIG_HOME/zsh/.zprofile"
df_symlink "$DOTFILESDIR/modules/zsh/mytheme.omp.json" "$XDG_CONFIG_HOME/oh-my-posh/mytheme.omp.json"

# used by zinit
df_package "file"
df_package "unzip"
df_package "tar"
df_package "curl"
df_package "wget"

df_package "zsh"
df_package "neovim"
df_package "varlad/zellij"
df_package "zellij"
