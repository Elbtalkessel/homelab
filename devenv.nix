{ config, pkgs, ... }:

{
  dotenv.enable = true;

  packages = with pkgs; [
    butane
  ];

  scripts = {
    # Syncs local stacks directory with remote.
    syncup.exec = ''
      rsync -Parvz bin coreos stacks ${config.env.SSH_USER}@${config.env.SSH_HOST}:${config.env.REMOTE_STACKS_DIR}/
    '';

    # Pulls stacks directory from server (only files present locally).
    syncdown.exec = ''
      rsync --existing -Parvz ${config.env.SSH_USER}@${config.env.SSH_HOST}:${config.env.REMOTE_STACKS_DIR}/ .
    '';

    ignite.exec = ''
      set -e
      for p in $@; do
        butane "$p" -d ${config.env.DEVENV_ROOT} --pretty > ''${p%.bu}.ign
        echo "''${p}.bu > ''${p%.bu}.ign"
      done
    '';
  };

  git-hooks.hooks = {
    ignite = {
      enable = true;
      name = "Ignite butane files";
      entry = "ignite";
      files = "\\.(bu)$";
      pass_filenames = true;
    };

    syncup = {
      enable = true;
      name = "Sending changes to remote host";
      entry = "syncup";
      pass_filenames = false;
    };
  };
}
