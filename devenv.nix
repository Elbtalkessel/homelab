{ config, ... }:

{
  dotenv.enable = true;

  scripts = {
    # Syncs local stacks directory with remote.
    syncup.exec = ''
      rsync -Parvz bin coreos stacks ${config.env.SSH_USER}@${config.env.SSH_HOST}:${config.env.REMOTE_STACKS_DIR}/
    '';

    # Pulls stacks directory from server (only files present locally).
    syncdown.exec = ''
      rsync --existing -Parvz ${config.env.SSH_USER}@${config.env.SSH_HOST}:${config.env.REMOTE_STACKS_DIR}/ .
    '';
  };

  git-hooks.hooks.syncup = {
    enable = true;
    name = "Sending changes to remote host";
    entry = "syncup";
    pass_filenames = false;
  };
}
