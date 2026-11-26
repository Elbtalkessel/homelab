{ pkgs, ... }:

{
  dotenv.enable = true;

  packages = with pkgs; [
    butane
    ansible
    ansible-lint
    # quadctl (bin/) is a Python CLI; PyYAML is used to read the defaults file
    # in flag mode (the JSON mode is stdlib-only).
    (python3.withPackages (ps: [ ps.pyyaml ]))
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
