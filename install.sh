#!/bin/bash -e

# Handle Args
while [ $# -gt 0 ]; do
  case $1 in
    --machine|-m)
      MACHINE=$2
      shift
      ;;
    --no-upgrade)
      NO_UPGRADE=1
      ;;
    *)
      {
        echo "install.sh [--machine]"

        echo "Options"
        echo ""
        echo "--machine|-m: Which machine is the installer running for."
        echo "    Can be one of 'hmdesk', 'winlap', 'splap'"
        echo "    'hmdesk' is for the home desktop running wsl"
        echo "    'winlap' is for a generic windows laptop running wsl"
        echo "    'splap' is for work laptop provided by synergi"
      } >&2
      exit;;
  esac
  shift
done

# Make sure we are using a valid machine name
if [ "$MACHINE" != "hmdesk" ] \
  && [ "$MACHINE" != "winlap" ] \
  && [ "$MACHINE" != "splap" ]
then
  printf "\e[1;31mError: --machine is not valid.\e[0m\n" >&2
  exit 1
fi

# Set WSL to 1 if machine is on wsl
if [ "$MACHINE" = "hmdesk" ] \
  || [ "$MACHINE" = "winlap" ] \
  || [ "$MACHINE" = "splap" ]
then
  WSL=1
fi

if [ -z "$NO_UPGRADE" ]; then
  # Install Updates
  sudo apt-get update
  sudo apt-get upgrade -y
fi

if [ -n "$WSL" ]; then
  # Update WSL Configuration
  sudo tee /etc/wsl.conf > /dev/null << EOF 
[boot]
systemd=true

[interop]
appendWindowsPath=false

[user]
default=$USER  
EOF
fi

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
nix run home-manager/master -- --flake ".#$MACHINE" switch

popd

mkdir -p "$HOME/.local/bin"

cat << EOF > "$HOME/.local/bin/hm"
#!/bin/sh -e
home-manager --flake "\$HOME/.config/home-manager#$MACHINE" "\$@"
EOF

chmod +x "$HOME/.local/bin/hm"

echo
echo "home-manager has been installed. Please restart to get latest changes."
