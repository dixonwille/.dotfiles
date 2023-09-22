{
  description = "Home Manager configuration of wdixon";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."hmdesk" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./instances/home-desktop.nix];
      };
      homeConfigurations."winlap" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./instances/windows-laptop.nix];
      };
      homeConfigurations."splap" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./instances/synergi-laptop];
      };
    };
}
