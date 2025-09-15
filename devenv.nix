{ config, pkgs, ... }:

{
  dotenv.enable = true;
  env = {
    DOCKER_HOST = "ssh://${config.env.SERVER}";
    CAROOT = "${config.env.DEVENV_ROOT}/caroot";
  };

  packages = with pkgs; [
    mkcert
  ];

  scripts = {
    sync.exec = ''
      rsync -Parvz compose ${config.env.SERVER}:~/
    '';

    dc.exec = ''
      group=$1
      if [ -z $group ]; then
        echo "Usage:"
        printf "  dc <group> <docker command> [service]\n"
        printf "  Where the <group> is a directory name and the compose/\n"
        printf "Example:\n"
        printf "  dc servarr logs -f radarr\n"
        exit 0
      fi
      shift

      rdir="compose/$group"
      compose=$(ls $rdir | grep docker-compose)
      if [ $? -ne 0 ]; then
        echo "A docker-compose file is not found in $rdir group."
        exit 1
      fi

      docker compose -f $rdir/$compose $@
    '';

    status.exec = ''
      docker ps --format 'table {{.Names|printf "%-20.20s"}} {{.Status}}'
    '';
  };
}
