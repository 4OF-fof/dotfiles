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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nixos-wsl,
    }:
    let
      canonicalUser = "fof";
      envOr =
        name: default:
        let
          value = builtins.getEnv name;
        in
        if value == "" then default else value;

      user = envOr "DOTFILES_USER" canonicalUser;

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

      mkDarwin =
        username:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              users.users.${username}.home = "/Users/${username}";
              home-manager.backupFileExtension = "old";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./nix/home.nix;
              system.primaryUser = username;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        mac = mkDarwin user;
      };

      nixosConfigurations = {
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            username = user;
          };
          modules = [
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            ./nix/wsl.nix
          ];
        };
      };

      homeConfigurations = {
        wsl = mkHome "x86_64-linux" user "/home/${user}" [ ./nix/modules/wsl-windows.nix ];
      };
    };
}
