{
  imports = [
    ./modules/packages.nix
    ./modules/apps/git.nix
    ./modules/apps/zsh.nix
    ./modules/apps/tmux.nix
    ./modules/apps/starship.nix
    ./modules/apps/nvim.nix
    ./modules/apps/wezterm.nix
    ./modules/apps/zed.nix
    ./modules/apps/opencode.nix
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
