
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.wsl;
in {
  options.profiles.wsl = {
    _1passwordAgent = {
      enable = mkEnableOption "1Password SSH Agent";
      socketFile = mkOption {
        type = types.str;
        description = "Path to the socket file";
      };
      npiperelayPath = mkOption {
        type = types.str;
        description = "Path to npiperelay.exe";
      };
    };
  };
  config = {
    home.packages = with pkgs; [
      wl-clipboard
      wslu
    ]
    ++ optional cfg._1passwordAgent.enable pkgs.socat;

    profiles.wsl._1passwordAgent.socketFile = mkDefault "${config.xdg.dataHome}/onepassword/agent.sock";
    profiles.wsl._1passwordAgent.npiperelayPath = mkDefault "/mnt/c/Users/${config.home.username}/bin/npiperelay.exe";

    home.sessionVariables.SSH_AUTH_SOCK = mkIf cfg._1passwordAgent.enable cfg._1passwordAgent.socketFile;

    systemd.user.services.onepassword = mkIf cfg._1passwordAgent.enable {
      Unit = {
        After = [ "network.target" ];
        Description = "1Password SSH Agent";
      };
      Service = {
        ExecStartPre = "rm -f ${cfg._1passwordAgent.socketFile}";
        ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:${cfg._1passwordAgent.socketFile},fork EXEC:'${cfg._1passwordAgent.npiperelayPath} -ei -s //./pipe/openssh-ssh-agent',nofork";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
