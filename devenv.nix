{ config, pkgs, ... }:

{
  dotenv.enable = true;

  packages = with pkgs; [
    butane
  ];

  scripts = {
    # Syncs local stacks directory with remote.
    syncup.exec = ''
      rsync -Parvz bin coreos stacks ${config.env.SSH_USER}@${config.env.SSH_HOST}:${config.env.REMOTE_DIR}/
    '';

    # Pulls stacks directory from server (only files present locally).
    syncdown.exec = ''
      rsync --existing -Parvz ${config.env.SSH_USER}@${config.env.SSH_HOST}:${config.env.REMOTE_DIR}/ .
    '';

    ignite.exec = ''
      set -e
      for p in $@; do
        butane "$p" -d ${config.env.DEVENV_ROOT} --pretty > ''${p%.*}.ign
        echo "''${p}.bu > ''${p%.*}.ign"
      done
    '';

    # A simple HTTP server serving any file.
    # By default responds with coreos/fcos.yaml in .ign format.
    # Usage:
    #   igniter [<./coreos/fcos.yaml>] [<8080>] [<0.0.0.0>]
    igniter.exec = ''
      set -e

      fpath=''${1:-${config.env.DEVENV_ROOT}/coreos/fcos.yaml}
      port=''${2:-8080}
      host='0.0.0.0'

      c() { printf "\033[''${1}m''${2}\033[0m"; }
      addr="http://$(hostname -I | cut --delimiter=' ' --fields=1):''${port}"
      echo "$(c 90 'Listening on') $(c 32 $host:$port) 🚀"
      echo "$(c 90 '$') $(c 32 "sudo coreos-installer install --insecure-ignition --ignition-url=$addr /dev/sda")"

      body() {
        if test "$(basename $fpath)" = "fcos.yaml"; then
          butane "$fpath" -d ${config.env.DEVENV_ROOT} --pretty
        else
          cat $fpath
        fi
      }

      while true; do
        { echo -e 'HTTP/1.1 200 OK\r\n'; body; } | nc -N -l $host $port
      done
    '';
  };

  git-hooks.hooks = {
    ignite = {
      enable = true;
      name = "Ignite butane files";
      entry = "ignite";
      files = "\\.(yaml|yml|bu)$";
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
