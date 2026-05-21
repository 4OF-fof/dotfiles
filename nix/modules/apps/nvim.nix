{ pkgs, ... }:

{
  home.packages = [ pkgs.neovim ];

  xdg.configFile."nvim".source = ../../../nvim;
}
