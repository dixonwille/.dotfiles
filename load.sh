#!/usr/bin/env bash
set -e

if [[ "$DOTFILESDIR" != "" ]]; then
  pushd "$DOTFILESDIR" &> /dev/null
  directed="1"
fi

source "scripts/config.sh"
source "scripts/functions.sh"
if [[ ! -e "$HOME/.local/bin/dfload" ]]; then
  mkdir -p "$HOME/.local/bin"
  df_symlink "$DOTFILESDIR/load.sh" "$HOME/.local/bin/dfload"
fi

if [[ -e "machine.sh" ]]; then
  source "machine.sh"
fi
source "machines/${DFCONF[MACHINE]}.sh"
load_inherit
load_modules
before_install
install_packages
after_install
create_symlinks

if [[ "$directed" == "1" ]]; then
  popd &> /dev/null
fi
