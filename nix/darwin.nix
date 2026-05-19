{ config, ... }:

let
  userHome = config.users.users.${config.system.primaryUser}.home;
in

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.zsh.enable = true;

  system.activationScripts.postActivation.text = ''
    echo "copying Home Manager applications..." >&2
    rm -rf "/Applications/Nix Apps"
    mkdir -p "/Applications/Nix Apps"
    for app in "${userHome}/Applications/Home Manager Apps"/*.app; do
      [ -e "$app" ] || continue
      target="/Applications/Nix Apps/$(basename "$app")"
      source="$(realpath "$app")"
      cp -cR "$source" "$target" 2>/dev/null || cp -R "$source" "$target"
    done
  '';

  system.stateVersion = 6;
}
