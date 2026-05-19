{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = "fof";
    startMenuLaunchers = true;
  };

  programs.zsh.enable = true;

  users.users.fof = {
    isNormalUser = true;
    description = "fof";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    backupFileExtension = "old";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.fof = import ./home.nix;
  };

  system.stateVersion = "24.11";
}
