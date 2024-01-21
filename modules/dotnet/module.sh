[[ "${DFLOADED[DOTNET]}" == "1" ]] && return
DFLOADED[DOTNET]="1"

load_module "microsoft"

df_package "dotnet-sdk-8.0"
df_package "dotnet-sdk-7.0"
df_package "dotnet-sdk-6.0"

# TODO: Install if work https://github.com/microsoft/artifacts-credprovider
