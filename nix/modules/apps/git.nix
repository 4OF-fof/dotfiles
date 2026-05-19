{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.dotfiles.git.windowsSettings = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Git settings used for the Windows gitconfig generated from WSL.";
  };

  config = {
    programs.git = {
      enable = true;
      package = pkgs.git;
      ignores = [ ".env" ];
      settings = {
        user = {
          name = "4OF";
          email = "4OF@4of.dev";
        };
        init.defaultBranch = "master";
      };
    };

    dotfiles.git.windowsSettings = config.programs.git.settings // {
      core.sshCommand = "C:/Windows/System32/OpenSSH/ssh.exe";
    };
  };
}
