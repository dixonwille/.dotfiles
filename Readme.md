# Bootstrap

## WSL2

- Update the system

```sh
sudo apt update && sudo apt upgrade -y
```

- Change `/etc/wsl.conf`

```toml
[boot]
systemd=true

[interop]
appendWindowsPath = false
```

- Install Nix

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```

- Run to verify (for some reason this is needed?)

```sh
nix-shell -p nix-info --run "nix-info -m"
```

- Update `/etc/nix/nix.conf`

```ini
build-users-group = nixbld
experimental-features = nix-command flakes
use-xdg-base-directories = true
```

- Reboot WSL
- Bootstrap home-manager with one of the following

```sh
# Doesn't clone but installs it from github (hard to modify if needed
nix run home-manager/master -- init --flake github:dixonwille/dotfiles --switch

# expected to be already cloned to .config/home-manager
nix run home-manager/master -- switch

# expected to be in the .config/home-manager folder
# allows you to change the "user"
nix run --no-write-lock-file github:nix-community/home-manager/ -- --flake ".#$USER" switch
```

- Make ZSH default for user

```sh
echo "$(which zsh)" | sudo tee -a /etc/shells
chsh -s "$(which zsh)"
```
