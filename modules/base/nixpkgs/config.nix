{ lib, ... }:
{
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
    "terraform"
  ];
}
