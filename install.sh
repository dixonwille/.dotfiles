#!/usr/bin/env bash
set -e

# get some machine information
isFedora="0"
command -v dnf > /dev/null
[[ "$?" == "0" ]] && isFedora="1"
isWsl="0"
[[ "$(uname -r)" == *WSL2 ]] && isWsl="1"

# handle args
MACHINE="default"
while [ $# -gt 0 ]; do
  case $1 in
    --machine|-m)
      MACHINE=$2
      shift
      ;;
    --user|-u)
      DFUSER=$2
      shift
      ;;
  esac
  shift
done

# install required packages
if [[ "$isFedora" == "1" ]]; then
  if [[ ! -f "/etc/yum.repos.d/1password.repo" ]]; then
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
    sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
  fi
  set +e
  sudo dnf check-update -y
  set -e
  sudo dnf upgrade -y
  sudo dnf install systemd passwd git 1password-cli util-linux -y
fi

# setup a user account
if [[ "$(whoami)" == "root" ]]; then
  if [[ "$isFedora" == "1" ]]; then
    if [[ "$DFUSER" == "" ]]; then
      read -p "Username: "
      DFUSER="$REPLY"
    fi
    useradd -G wheel "$DFUSER"
    passwd "$DFUSER"
    if [[ $# -eq 0 ]]; then
      sudo -i -u "$DFUSER" -H "bash <(curl -L https://raw.githubusercontent.com/dixonwille/dotfiles/main/install.sh)"
    else
      sudo -i -u "$DFUSER" -H "bash <(curl -L https://raw.githubusercontent.com/dixonwille/dotfiles/main/install.sh) -- $@"
    fi
  else
    echo "---Unkown OS, please setup a user first"
    exit 1
  fi
fi

# Setup WSL file
if [[ "$isWsl" == "1" ]]; then
sudo tee /etc/wsl.conf >  /dev/null << EOF
[boot]
systemd=true

[interop]
appendWindowsPath=false

[user]
default=$DFUSER
EOF
fi

XDG_CACHE_HOME="$HOME/.cache"
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"
DOTFILESDIR="$XDG_DATA_HOME/dotfiles"

git clone https://github.com/dixonwille/dotfiles "$DOTFILESDIR"

pushd "$DOTFILESDIR" 2>&1 > /dev/null

if [[ ! -f "machines/$MACHINE.sh" ]]; then
  echo "---Could not find machine named $MACHINE"
  exit 1
fi

echo "DFCONF[MACHINE]=\"$MACHINE\"" > "machine.sh"

./load.sh

git remote set-url origin git@github.com:dixonwille/dotfiles.git

zshBin=$(command -v "zsh")
if [[ "$zshBin" != "" ]]; then
  chsh -s "$zshBin"
fi

popd 2>&1 > /dev/null
