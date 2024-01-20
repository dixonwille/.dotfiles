#!/usr/bin/env bash
set -e

echo "$#"

source "scripts/config.sh"
source "scripts/functions.sh"
if [[ -e "machine.sh" ]]; then
  source "machine.sh"
fi
source "machines/${DFCONF[MACHINE]}.sh"
load_inherit
load_modules
install_packages
after_install
create_symlinks
