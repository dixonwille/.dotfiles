# Dotfiles

```sh
bash <(curl -L https://raw.githubusercontent.com/dixonwille/dotfiles/main/install.sh)
```

Can supply:

- `--machine|-m` for the machine to configure
- `--user|-u` for the user to create if executing from root user

## Grab Fedora for WSL2

[Fedora Container Base](https://koji.fedoraproject.org/koji/packageinfo?packageID=26387)

```sh
tar -xf Fedora-Container-Base-<VERSION>.<ARCH>.tar.xz
```

Use the layer file to create the base wsl2 image.

```sh
wsl --import Fedora $HOME\wsl\Fedora $LOCATION_TO_LAYER\layer.tar
```

## Issues with Ping

Add this to `.wslconfig` file.

```toml
[wsl2]
kernelCommandLine = sysctl.net.ipv4.ping_group_range=\"0 2147483647\"
```

## 1Password Choose SSH Key

If in WSL2, you will need to add the following example to `%USERPROFILE%\.ssh\config`

```
Host ssh.dev.azure.com
    IdentityFile ~/.ssh/devops.pub
    IdentitiesOnly yes
```

You will need to download the public key to the specified path

## WSL2 VPN

To allow WSL2 to access a VPN connected in Windows add this to `.wslconfig` file.

```toml
[wsl2]
networkingMode = mirrored
dnsTunneling = true
```
