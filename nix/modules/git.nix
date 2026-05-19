{
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;
    package = pkgs.git;
    ignores = [ ".env" ];
    settings =
      {
        user = {
          name = "4OF";
          email = "4OF@4of.dev";
        };
        init.defaultBranch = "master";
      };
  };
}
