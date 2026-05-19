{
  config,
  lib,
  pkgs,
  ...
}:

let
  windowsUser = "fof";
  windowsHome = "/mnt/c/Users/${windowsUser}";
  windowsGitConfig = pkgs.writeText "windows-gitconfig" (
    lib.generators.toGitINI (
      config.programs.git.settings
      // {
        core.sshCommand = "C:/Windows/System32/OpenSSH/ssh.exe";
      }
    )
  );
in
{
  home.activation.installWindowsDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    windows_home=${lib.escapeShellArg windowsHome}

    if [ -d "$windows_home" ]; then
      $DRY_RUN_CMD mkdir -p "$windows_home/Documents/PowerShell/module"
      $DRY_RUN_CMD cp -f ${../../pwsh/Microsoft.PowerShell_profile.ps1} "$windows_home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1"
      $DRY_RUN_CMD cp -f ${../../pwsh/module}/*.ps1 "$windows_home/Documents/PowerShell/module/"
      $DRY_RUN_CMD cp -f ${windowsGitConfig} "$windows_home/.gitconfig"
    else
      echo "Skipping Windows dotfiles: $windows_home does not exist"
    fi
  '';
}
