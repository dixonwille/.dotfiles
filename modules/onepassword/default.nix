{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.dixonwille.onepassword;
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

  newLineSep = fn: input: lib.concatStringsSep "\n" (lib.mapAttrsToList fn input);

  hasSessionVariables = account: account.sessionVariables != { };
  filterAccountsWithSessionVariables = accounts: lib.filterAttrs (short: account: hasSessionVariables account) accounts;
  anyAccountHasSessionVariables = accounts: lib.any (v: v) (lib.mapAttrsToList (short: account: hasSessionVariables account) accounts);

  accountShellAlias = short: lib.nameValuePair "op${short}" "eval $(op signin --account ${short})";

  exportVariable = n: v: ''export ${n}="${toString v}"'';
  exportAllVariables = newLineSep exportVariable;

  accountEnvFile = short: account: pkgs.writeText "${short}_secrets.env" (exportAllVariables account.sessionVariables);

  accountShellArgs = short: account: ''"${short}" "${account.address}" "${account.email}"'';
  
  verifyForAccount = short: account: ''accurateOnePasswordAccount ${accountShellArgs short account}'';
  verifyAccounts = newLineSep verifyForAccount;

  addAccount = short: account: ''addOnePasswordAccountIfNotExists ${accountShellArgs short account}'';
  addAllAccounts = newLineSep addAccount;

  signInAndInject = short: account: ''
    signinOnePasswordAccount "${short}"
    injectOnePasswordIntoFile "${cfg.envPackages."${short}"}" "${envFilePath}"
  '';
  signInAndInjectAll = newLineSep signInAndInject;

in {
  options.dixonwille.onepassword = {
    enable = mkEnableOption "Enable 1Password integrations";
    package = mkPackageOption pkgs "_1password" { };
    accounts = mkOption {
      type = types.attrsOf accountSubmodule;
      description = "Accounts to connect to 1Password";
    };
    envPackages = mkOption {
      type = with types; attrsOf package;
      internal = true;
      description = "The package containing the environment variables that need to be set";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.extraActivationPath = [ cfg.package ];
    home.shellAliases = (lib.mapAttrs' (short: account: accountShellAlias short) cfg.accounts);
    dixonwille.onepassword.envPackages = (lib.mapAttrs accountEnvFile (filterAccountsWithSessionVariables cfg.accounts));
    home.activation.verifyOnePassword = hm.dag.entryBefore ["writeBoundary"] ''
      ${builtins.readFile ./verify.sh}
      ${verifyAccounts cfg.accounts}
    '';
    home.activation.onePassword = hm.dag.entryAfter ["writeBoundary"] (''
      ${builtins.readFile ./activate.sh}
    '' + lib.optionalString (anyAccountHasSessionVariables cfg.accounts) ''
      if [ ! -v DRY_RUN ]; then
        mkdir -p $(dirname "${envFilePath}")
        touch "${envFilePath}"
        chmod 0600 "${envFilePath}"
      fi
    '' + ''
      ${addAllAccounts cfg.accounts}
      ${signInAndInjectAll (filterAccountsWithSessionVariables cfg.accounts)}
    '');
    home.sessionVariablesExtra = lib.optionalString (anyAccountHasSessionVariables cfg.accounts) ''source ${envFilePath}'';
  };
}
