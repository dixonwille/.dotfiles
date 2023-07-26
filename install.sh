#!/bin/bash -e

# Install Updates
sudo apt-get update
sudo apt-get upgrade -y

# Update WSL Configuration
sudo tee /etc/wsl.conf > /dev/null << EOF 
[boot]
systemd=true

[interop]
appendWindowsPath=false

[user]
default=$USER
EOF

# Need some extra arguments for nix
nixExtra=$(mktemp)
cat << EOF > $nixExtra
experimental-features = nix-command flakes
use-xdg-base-directories = true
EOF

# Install nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes --nix-extra-conf-file $nixExtra

# Source RC file again to get the nix executable
. /etc/bashrc

# This is needed to setup a few directories and does a nice health check to make sure things are working
nix shell nixpkgs#nix-info --command nix-info -m

# Clone down the dotfile repository
nix flake clone github:dixonwille/dotfiles --dest $HOME/.config/home-manager

pushd $HOME/.config/home-manager >/dev/null

# Use SSH for git
git remote set-url origin git@github.com:dixonwille/dotfiles

# Switch to using the new profile
nix run home-manager/master -- --flake ".#$USER" switch

popd

echo
echo "home-manager has been installed. Please restart to get latest changes."
