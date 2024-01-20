[[ "${DFLOADED[GO]}" == "1" ]] && return
DFLOADED[GO]="1"

df_package "golang"
