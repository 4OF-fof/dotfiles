{
  programs.tmux = {
    enable = true;
    mouse = true;
    extraConfig = builtins.readFile ../../tmux/module/theme.conf;
  };
}
