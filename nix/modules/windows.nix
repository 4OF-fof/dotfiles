{
  config,
  lib,
  pkgs,
  ...
}:

let
  windowsHome = "/mnt/c/Users/fof";
  powerShellProfile = ../../pwsh/Microsoft.PowerShell_profile.ps1;
  powerShellModule = ../../pwsh/module;
  zedSettings = pkgs.writeText "zed-settings.json" config.xdg.configFile."zed/settings.json".text;
in
{
  home.activation.windowsPowerShell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${windowsHome}/Documents/PowerShell"
    ${pkgs.coreutils}/bin/mkdir -p "$target/module"
    ${pkgs.coreutils}/bin/install -m 0644 ${powerShellProfile} "$target/Microsoft.PowerShell_profile.ps1"
    ${pkgs.coreutils}/bin/rm -rf "$target/module"
    ${pkgs.coreutils}/bin/mkdir -p "$target/module"
    ${pkgs.coreutils}/bin/cp -R ${powerShellModule}/. "$target/module/"
    ${pkgs.findutils}/bin/find "$target/module" -type f -name '*.ps1' -exec ${pkgs.coreutils}/bin/chmod 0644 {} +
  '';

  home.activation.windowsZed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${windowsHome}/AppData/Roaming/Zed"
    ${pkgs.coreutils}/bin/mkdir -p "$target"
    ${pkgs.coreutils}/bin/install -m 0644 ${zedSettings} "$target/settings.json"
  '';
}
