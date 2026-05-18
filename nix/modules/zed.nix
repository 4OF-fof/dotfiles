{ lib, pkgs, ... }:

let
  settings = {
    languages.WIT.enable_language_server = false;
    edit_predictions.provider = "copilot";
    language_models.opencode = {
      show_free_models = false;
      show_zen_models = false;
    };
    agent_servers.opencode = {
      type = "registry";
      favorite_config_option_values.model = [
        "opencode-go/kimi-k2.6"
        "opencode-go/qwen3.6-plus"
      ];
    };
    project_panel.dock = "left";
    outline_panel.dock = "left";
    collaboration_panel.dock = "left";
    agent = {
      default_model = {
        provider = "opencode";
        model = "go/qwen3.6-plus";
        enable_thinking = false;
      };
      dock = "right";
      favorite_models = [
        {
          provider = "opencode";
          model = "go/kimi-k2.6";
          enable_thinking = false;
        }
        {
          provider = "opencode";
          model = "go/qwen3.6-plus";
          enable_thinking = false;
        }
      ];
      model_parameters = [ ];
    };
    git_panel.dock = "left";
    icon_theme = "Material Icon Theme";
    buffer_font_family = "UDEV Gothic NFLG";
    session.trust_all_worktrees = true;
    vim_mode = false;
    ui_font_size = 16;
    buffer_font_size = 15;
    theme = {
      mode = "system";
      light = "One Light";
      dark = "One Dark";
    };
    auto_install_extensions = {
      html = true;
      toml = true;
      lua = true;
      "git-firefly" = true;
      "material-icon-theme" = true;
      opencode = true;
    };
  };
in
{
  xdg.configFile = {
    "zed/settings.json".text = builtins.toJSON settings;
    "zed/settings.json".enable = pkgs.stdenv.hostPlatform.isDarwin;
  };
}
