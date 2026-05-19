{ pkgs, ... }:

{
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
    };
  };
}
