df_before_install "sudo dnf config-manager --add-repo https://packages.microsoft.com/config/fedora/39/prod.repo"
df_before_install "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"

df_package "powershell"
