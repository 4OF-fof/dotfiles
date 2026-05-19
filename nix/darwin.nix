{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.zsh.enable = true;

  system.activationScripts.postActivation.text = ''
    echo "linking Home Manager applications..." >&2
    rm -rf "/Applications/Nix Apps"
    mkdir -p "/Applications/Nix Apps"
    for app in "/Users/mukai/Applications/Home Manager Apps"/*.app; do
      [ -e "$app" ] || continue
      ln -s "$app" "/Applications/Nix Apps/$(basename "$app")"
    done
  '';

  system.primaryUser = "mukai";
  system.stateVersion = 6;
}
