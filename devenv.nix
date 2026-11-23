{ pkgs, ... }:

{
  dotenv.enable = true;

  packages = with pkgs; [
    butane
    ansible
    ansible-lint
  ];

  enterShell = ''
    export PATH="$DEVENV_ROOT/bin:$PATH"
  '';

  git-hooks.hooks = {
    check-butane = {
      enable = true;
      name = "Check butane";
      entry = "bu-check";
      files = "butane/.*\\.(yaml|yml|bu)$";
      pass_filenames = true;
    };
  };
}
