{ config, pkgs, lib, ... }:

with lib;

let 
   cfg = config.profiles.synergi-laptop;
   azDevOpsCommitFile = ".ssh/azDevOpsCommit.pub";
in {
  options.profiles.synergi-laptop = {};
  config = {
    home.file = {
      "${azDevOpsCommitFile}" = {
        enable = true;
        source = ./files/azDevOpsCommit.pub;
      };
    };
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "ssh.dev.azure.com" = {
          identitiesOnly = true;
          identityFile = "${config.home.homeDirectory}/${azDevOpsCommitFile}";
        };
      };
    };
  };
}
