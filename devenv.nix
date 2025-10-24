{ config, pkgs, ... }:

{
  dotenv.enable = true;

  packages = with pkgs; [
    butane
  ];

  scripts =
    let
      fcos-install-cmd = "sudo coreos-installer install --insecure-ignition --ignition-url";
      ssh-uri = "${config.env.SSH_USER}@${config.env.SSH_HOST}";
    in
    {
      get-sos-report.exec = ''
        scp ${config.env.PROXMOX_USER}@${config.env.PROXMOX_HOST}:/srv/shared/rdsosreport.txt .
        if test $? -ne 0; then
          echo "SOS report not found or cannot connect to server."
          echo "To generate report, create directory mapping in Proxmox > Datacenter."
          echo "Locate failing VM add virtiofs device. Reboot VM. Drop into terminal."
          echo "sudo mount -t virtiofs <mapping-id> /mnt/shared"
        fi
      '';

      # Syncs local stacks directory with remote.
      syncup.exec = ''
        rsync -Parvz bin coreos stacks ${ssh-uri}:${config.env.REMOTE_DIR}/
      '';

      # Pulls stacks directory from server (only files present locally).
      syncdown.exec = ''
        rsync --existing -Parvz ${ssh-uri}:${config.env.REMOTE_DIR}/ .
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

      auto-ignite.exec = ''
        port='${config.env.IGNITION_PORT}'
        addr="http://$(hostname -I | cut --delimiter=' ' --fields=1):''${port}"
        ssh $1 "${fcos-install-cmd}=$addr /dev/sda && reboot"
      '';

      igniter.exec = ''
        set -e

        fpath='${config.env.DEVENV_ROOT}/${config.env.BUTANE_FILE}'
        port='${config.env.IGNITION_PORT}'
        host='0.0.0.0'

        c() { printf "\033[''${1}m''${2}\033[0m"; }
        addr="http://$(hostname -I | cut --delimiter=' ' --fields=1):''${port}"
        echo "$(c 90 'Listening on') $(c 32 $host:$port) 🚀"
        echo "$(c 90 'Run') $(c 32 "${fcos-install-cmd}=$addr /dev/sda")"
        echo "Or auto-ignite <server-ip>"

        body() {
          butane "$fpath" -d ${config.env.DEVENV_ROOT} --pretty
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
      files = "coreos/\\.(yaml|yml|bu)$";
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
