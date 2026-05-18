{ lib, pkgs, ... }:

{
  xdg.configFile = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    "wezterm/wezterm.lua".text = builtins.readFile ../../wezterm/wezterm.lua;
  };
}
