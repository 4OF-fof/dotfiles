{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.zsh.enable = true;

  system.primaryUser = "fof";
  system.stateVersion = 6;
}
