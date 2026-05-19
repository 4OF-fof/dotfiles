{ pkgs, username, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
  };

  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    backupFileExtension = "old";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      imports = [
        ./home.nix
        ./modules/platforms/wsl-windows.nix
      ];
    };
  };

  system.stateVersion = "24.11";
}
