[[ "${DFLOADED[POWERSHELL]}" == "1" ]] && return
DFLOADED[POWERSHELL]="1"

load_module "microsoft"

df_package "powershell"

if [[ "${DFCONF[IS_WORK]}" == "1" ]]; then
  df_after_install "pwsh -Command 'if (-not (Get-Module -ListAvailable -Name Az)) {Install-Module -Name Az -Repository PSGallery -Force}'"
  df_after_install "pwsh -Command 'if (-not (Get-Module -ListAvailable -Name AzureAD)) {Install-Module -Name AzureAD -Repository PSGallery -Force}'"
fi
