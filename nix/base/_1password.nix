{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.base._1password;
  envFilePath = "${config.xdg.dataHome}/onepassword/secrets.env";

  accountSubmodule = types.submodule {
    options = {
      address = mkOption {
        default = "my.1password.com";
        type = types.str;
        description = "The sign-in address for your account";
        example = "my.1password.com";
      };
      email = mkOption {
        type = types.str;
        description = "The email address associated with your account";
      };
      sessionVariables = mkOption {
        default = {};
        type = with types; attrsOf str;
        description = "Environment Variables to set that are secrets read from 1Password";
        example = literalExpression ''
          {
            SOME_SECRET = "op://private/super-secret/password"
            ANOTHER_SECRET = "op://Shared/another-secret/key"
          }
        '';
      };
    };
  };

  hasSessionVariables = short: account: account.sessionVariables != { };
  anyAccountHasSessionVariables = lib.any (v: v) (lib.mapAttrsToList hasSessionVariables cfg.accounts);

  getAccountAliases = short: account: lib.nameValuePair "op${short}" "eval $(op signin --account ${short})";

  getEnvPackage = short: account: builtins.toFile "${short}_1password.env" (config.lib.shell.exportAll account.sessionVariables);

  getVerifyForAccount = short: account: ''
    $VERBOSE_ECHO "Checking 1Password accounts for ${short}"
    onePasswordExisting${short}=$(echo "$onePasswordAccounts" | grep '^${short}\s')
    if [[ $? -ne 0 ]]; then
      $VERBOSE_ECHO "1Password account for ${short} not found"
      onePasswordAdd${short}=1
    else
      $VERBOSE_ECHO "Checking 1Password account for ${short} has changed"
      echo "$onePasswordExisting${short}" | grep '^${short}\s\+https://${account.address}\s\+${account.email}\s' > "$DRY_RUN_NULL"
      if [[ $? -ne 0 ]]; then
        echo "1Password account \"${short}\" already exists but with different configuration"
        echo "Please remove the account before applying"
        exit 1
      fi
    fi
  '';

  getActivationForAccount = short: account: ''
    if [[ $onePasswordAdd${short} ]]; then
      $VERBOSE_ECHO "Adding 1Password account for ${short}"
      eval $(op account add --address "${account.address}" --email "${account.email}" --shorthand "${short}" --signin)
  '' + lib.optionalString (hasSessionVariables short account) ''
    else
      $VERBOSE_ECHO "Signing into 1Password account for ${short}"
      eval $(op signin --account ${short})
  '' + ''
    fi
  '' + lib.optionalString (hasSessionVariables short account)''
    $VERBOSE_ECHO "Injecting 1Password secrets for ${short}"
    cat "${cfg.envPackages."${short}"}" | op inject >> "${envFilePath}"
  '';

  activation = ''
    onePasswordAccounts=$(op account list)

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList getVerifyForAccount cfg.accounts)}

    set -e
    set -o pipefail

  '' + lib.optionalString (anyAccountHasSessionVariables) ''
    mkdir -p $(dirname "${envFilePath}")
    touch "${envFilePath}"
    chmod 0600 "${envFilePath}"
  '' + ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList getActivationForAccount cfg.accounts)}
  '';
in {
  options.profiles.base._1password = {
    enable = mkEnableOption "Enable 1Password integrations";
    accounts = mkOption {
      default = { my = { email = "dixonwille@gmail.com"; }; };
      type = types.attrsOf accountSubmodule;
      description = "Accounts to connect to 1Password";
    };
    envPackages = mkOption {
      type = with types; attrsOf package;
      internal = true;
      description = "The package containing the environment variables that need to be set";
    };
    activationPackage = mkOption {
      type = types.package;
      internal = true;
      description = "The package containing the activation script";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      _1password
    ];
    home.extraActivationPath = with pkgs; [
      _1password
    ];
    home.shellAliases = (lib.mapAttrs' getAccountAliases cfg.accounts); 
    profiles.base._1password.envPackages = (lib.mapAttrs getEnvPackage (lib.filterAttrs hasSessionVariables cfg.accounts));
    profiles.base._1password.activationPackage = pkgs.writeShellScript "1passwordActivation.sh" activation;
    home.activation.inject1PasswordSecrets = hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${cfg.activationPackage}
    '';
    programs.zsh = mkIf anyAccountHasSessionVariables {
      envExtra = "source ${envFilePath}";
    };
  };
}
