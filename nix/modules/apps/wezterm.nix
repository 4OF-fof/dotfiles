{ lib, pkgs, ... }:

{
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    pkgs.wezterm
  ];

  xdg.configFile = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    "wezterm/wezterm.lua".text = builtins.readFile ../../wezterm/wezterm.lua;
  };
}
