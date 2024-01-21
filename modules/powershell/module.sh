[[ "${DFLOADED[POWERSHELL]}" == "1" ]] && return
DFLOADED[POWERSHELL]="1"

load_module "microsoft"

df_package "powershell"
