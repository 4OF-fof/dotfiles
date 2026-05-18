{
  home.file = {
    ".zprofile".text = builtins.readFile ../../zsh/.zprofile;
    ".zshrc".text = builtins.readFile ../../zsh/.zshrc;
    ".zsh_module/alias/alias.zsh".text = builtins.readFile ../../zsh/module/alias/alias.zsh;
    ".zsh_module/abbr/abbr.zsh".text = builtins.readFile ../../zsh/module/abbr/abbr.zsh;
    ".zsh_module/zoxide/zoxide.zsh".text = builtins.readFile ../../zsh/module/zoxide/zoxide.zsh;
  };

  xdg.configFile."sheldon/plugins.toml".text = builtins.readFile ../../zsh/sheldon/plugins.toml;
}
