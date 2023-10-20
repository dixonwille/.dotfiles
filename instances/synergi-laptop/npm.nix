{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.synergi-laptop.npm;
in {
  options.profiles.synergi-laptop.npm = {};
  config = {
    home.packages = with pkgs; [
      nodejs_18
    ];
    home.sessionVariables = {
      NPM_CONFIG_USERCONFIG="${config.xdg.configHome}/npm/npmrc";
    };
    dixonwille.onepassword.accounts.sy.sessionVariables = {
      SYNERGI_ARTIFACTS_PAT_BASE64 = "op://tezpe7lkur4l2faazekanwftw4/lti7rfhwjxum6swoakcyhgyf7y/b64credential";
      SYNERGI_ARTIFACTS_PAT = "op://tezpe7lkur4l2faazekanwftw4/lti7rfhwjxum6swoakcyhgyf7y/credential";
    };
    xdg.configFile = {
      "npm/npmrc" = {
        enable =  true;
        source = ./files/npmrc;
      };
    };
  };
}
