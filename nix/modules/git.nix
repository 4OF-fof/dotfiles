{
  lib,
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;
    ignores = [ ".env" ];
    settings =
      {
        user = {
          name = "4OF";
          email = "4OF@4of.dev";
        };
        init.defaultBranch = "master";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isWindows {
        core.sshCommand = "C:/Windows/System32/OpenSSH/ssh.exe";
      };
  };
}
