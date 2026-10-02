# Work machine (WSL) tools, added to the nix profile beside global.nix
# (install/work).
# Must not share a package with another set installed on the same machine.
{ pkgs }:
pkgs.buildEnv {
  name = "dotfiles-work";
  paths = with pkgs; [
    # Extensions are part of the package: `az extension add` can't install into
    # it, so add them here instead. Not buildable in nixpkgs (their pins don't
    # match its Python libraries): containerapp (core az has `az containerapp`,
    # without the previews) and redisenterprise.
    (azure-cli.withExtensions (
      with azure-cli.extensions;
      [
        application-insights
        automation
        azure-devops
        cdn
        front-door
        log-analytics
        resource-graph
        storage-blob-preview
      ]
    ))
    # Rootless, with the system's setuid newuidmap/newgidmap (apt's uidmap) and
    # /etc/subuid ranges; config in the containers stow package. Its user units
    # are linked by install/work (`systemctl --user start podman.socket`).
    podman
    powershell
    # Az modules, just the ones scripts use (pkgs/pwsh-modules/modules.json);
    # on PSModulePath from personal/zsh-work's env.d
    (import ../pkgs/pwsh-modules.nix { inherit pkgs; })
    datadog-pup # pup
    sqlcmd # go-sqlcmd
    pulumi-bin
    terraform
    redis # redis-cli
    # Can't connect to a 1Password desktop app: on Linux that needs op to be
    # setgid onepassword-cli, which a nix store path can't be. Signs in with
    # `op signin` instead (zsh/.zshenv's _cache_op_secret).
    _1password-cli

    xdg-utils # xdg-open (Neovim's gx, Go's browser logins), which hands links to $BROWSER
    wsl-open # $BROWSER: opens links and files in Windows
    wl-clipboard # wl-copy and Neovim's clipboard, through WSLg
  ];
}
