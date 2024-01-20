[[ "${DFLOADED[RUST]}" == "1" ]] && return
DFLOADED[RUST]="1"

df_package "rust"
df_package "cargo"
