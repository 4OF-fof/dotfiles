{ lib, pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      bat
      fd
      fzf
      gh
      git
      lazygit
      lsd
      neovim
      opencode
      ripgrep
      sheldon
      starship
      tmux
      uv
      yazi
      zoxide
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      wezterm
      zed-editor
    ];
}
