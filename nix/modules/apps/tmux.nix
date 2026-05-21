{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    mouse = true;
    extraConfig = builtins.readFile ../../../tmux/module/theme.conf;
  };
}
