[[ "${DFLOADED[RUST]}" == "1" ]] && return
DFLOADED[RUST]="1"

df_package "rust"
df_package "cargo"
source "$DOTFILESDIR/modules/rust/environment"
df_after_install "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none --no-modify-path -y"
df_after_install "rustup toolchain link system /usr"
df_after_install "rustup default system"
