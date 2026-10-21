{ pkgs, ... }:

{
  dotenv.enable = true;

  packages = with pkgs; [
    butane
    ansible
  ];

  enterShell = ''
    export PATH="$DEVENV_ROOT/bin:$PATH"
  '';

  git-hooks.hooks = {
    check-butane = {
      enable = true;
      name = "Check butane";
      entry = "bu-check";
      files = "devops/butane/.*\\.(yaml|yml|bu)$";
      pass_filenames = true;
    };

    syncup = {
      enable = false;
      name = "Sending changes to remote host";
      entry = "syncup";
      pass_filenames = false;
    };
  };
}
