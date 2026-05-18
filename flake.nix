{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
    }:
    let
      mkHome =
        system: username: homeDirectory: extraModules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            ./nix/home.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ] ++ extraModules;
        };
    in
    {
      darwinConfigurations = {
        mac = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              users.users.fof.home = "/Users/fof";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.fof = import ./nix/home.nix;
            }
          ];
        };
      };

      homeConfigurations = {
        wsl = mkHome "x86_64-linux" "fof" "/home/fof" [
          ./nix/modules/windows.nix
        ];
      };
    };
}
