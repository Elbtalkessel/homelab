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

    bu-check.exec = ''
      code=0

      for p in $@; do
        err=$(butane "$p" -d ${config.env.DEVENV_ROOT} -c 2>&1)
        printf "\033[90m''${p}:\033[0m "
        if test -n "$err"; then
          printf "\033[31m''${err}\033[0m\n"
          code=1
        else
          printf "\033[32mOK\033[0m\n"
        fi
      done

      exit $code
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
    check-butane = {
      enable = true;
      name = "Check butane";
      entry = "bu-check";
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
