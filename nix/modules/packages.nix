{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    fd
    fzf
    gh
    lazygit
    lsd
    ripgrep
    uv
    yazi
    zoxide
  ];
}
