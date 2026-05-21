{
  config,
  lib,
  pkgs,
  ...
}:

let
  windowsGitConfig = pkgs.writeText "windows-gitconfig" (
    lib.generators.toGitINI config.dotfiles.git.windowsSettings
  );
in
{
  home.activation.installWindowsDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    windows_user=""

    if command -v cmd.exe >/dev/null 2>&1; then
      windows_user="$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r' | tail -n 1)"
    fi

    if [ -z "$windows_user" ]; then
      windows_user=${lib.escapeShellArg config.home.username}
    fi

    windows_home="/mnt/c/Users/$windows_user"

    if [ -d "$windows_home" ]; then
      $DRY_RUN_CMD mkdir -p "$windows_home/Documents/PowerShell/module"
      $DRY_RUN_CMD cp -f ${../../../pwsh/Microsoft.PowerShell_profile.ps1} "$windows_home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1"
      $DRY_RUN_CMD cp -f ${../../../pwsh/module}/*.ps1 "$windows_home/Documents/PowerShell/module/"
      $DRY_RUN_CMD cp -f ${windowsGitConfig} "$windows_home/.gitconfig"
    else
      echo "Skipping Windows dotfiles: $windows_home does not exist"
    fi
  '';
}
