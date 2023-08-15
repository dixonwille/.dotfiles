
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.base.wsl;
in {
  options.profiles.base.wsl = {
    enable = mkEnableOption "This is a WSL environment";
    windows = {
      username = mkOption {
        type = types.str;
        description = "Username of your windows user";
      };
      homeDirectory = mkOption {
        type = types.str;
        description = "Home directory of the windows user mapped in WSL";
      };
    };
    _1password = {
      socketFile = mkOption {
        type = types.str;
        description = "Path to the socket file";
      };
      npiperelayPath = mkOption {
        type = types.str;
        description = "Path to npiperelay.exe";
      };
      signExe = mkOption {
        type = types.str;
        description = "Path to op-ssh-sign.exe";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      wslu
    ]
    ++ optional config.profiles.base._1password.enable pkgs.socat;

    profiles.base.wsl.windows.username = mkDefault config.home.username;
    profiles.base.wsl.windows.homeDirectory = mkDefault "/mnt/c/Users/${cfg.windows.username}";

    profiles.base.wsl._1password.socketFile = mkDefault "${config.xdg.dataHome}/onepassword/agent.sock";
    profiles.base.wsl._1password.npiperelayPath = mkDefault "${cfg.windows.homeDirectory}/bin/npiperelay.exe";
    profiles.base.wsl._1password.signExe = mkDefault "${cfg.windows.homeDirectory}/AppData/Local/1Password/app/8/op-ssh-sign.exe";

    programs.git.extraConfig = mkIf (config.profiles.base.git.signing.enable && config.profiles.base._1password.enable) {
      gpg = {
        format = "ssh";
        ssh = {
          program = cfg._1password.signExe;
        };
      };
    };

    home.sessionVariables.SSH_AUTH_SOCK = mkIf config.profiles.base._1password.enable cfg._1password.socketFile;
    systemd.user.services.onepassword = mkIf config.profiles.base._1password.enable {
      Unit = {
        After = [ "network.target" ];
        Description = "1Password SSH Agent";
      };
      Service = {
        ExecStartPre = [
          "-/bin/mkdir -p $(dirname ${cfg._1password.socketFile})"
          "/bin/rm -f ${cfg._1password.socketFile}"
        ];
        ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:${cfg._1password.socketFile},fork EXEC:'${cfg._1password.npiperelayPath} -ei -s //./pipe/openssh-ssh-agent',nofork";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
