{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.zsh.enable = true;

  system.primaryUser = "mukai";
  system.stateVersion = 6;
}
