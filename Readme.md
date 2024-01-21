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
