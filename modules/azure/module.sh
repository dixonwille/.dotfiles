[[ "${DFLOADED[AZURE]}" == "1" ]] && return
DFLOADED[AZURE]="1"

load_module "microsoft"

df_package "azure-cli"
