{
  imports = [
    ./modules/packages.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/starship.nix
    ./modules/nvim.nix
    ./modules/wezterm.nix
    ./modules/zed.nix
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
