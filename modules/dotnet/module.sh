[[ "${DFLOADED[DOTNET]}" == "1" ]] && return
DFLOADED[DOTNET]="1"

dotnetDir="$XDG_DATA_HOME/dotnet"
mkdir -p "$dotnetDir"

curl -sSL https://dot.net/v1/dotnet-install.sh > "$dotnetDir/dotnet-install.sh"
chmod +x "$dotnetDir/dotnet-install.sh"

dotnet_install() {
  "$dotnetDir/dotnet-install.sh" --channel "$1" --install-dir "$dotnetDir"
}

df_package "krb5-libs"
df_package "libicu"
df_package "openssl-libs"
df_package "zlib"

df_after_install "dotnet_install LTS"

df_symlink "$dotnetDir/dotnet" "$HOME/.local/bin/dotnet"
df_symlink "$dotnetDir/dotnet-install.sh" "$HOME/.local/bin/dotnet-install"

if [[ "${DFCONF[IS_WORK]}" == "1" ]]; then
  mkdir -p "$HOME/.nuget/plugins"
  curl -H "Accept: application/octet-stream" \
    -L "https://github.com/Microsoft/artifacts-credprovider/releases/latest/download/Microsoft.Net6.NuGet.CredentialProvider.tar.gz" \
    | tar -xz -C "$HOME/.nuget/" "plugins/netcore"
fi
