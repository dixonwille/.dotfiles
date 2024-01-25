DFCONF[IS_WORK]="1"
df_inherit "default"

df_module "azure"
df_module "powershell"
df_module "dotnet"

# dotnet_install available via dotnet module
# vfox can only support down to 6.0 right now...
df_after_install "dotnet_install 3.1"
df_after_install "dotnet_install 5.0"
df_after_install "dotnet_install 6.0"
df_after_install "dotnet_install 7.0"
