{ config, pkgs, lib, ... }:

let
  dockgeUser = "tsukia"; # Change to dedicated podman user later
  homeDir = "/home/${dockgeUser}";
in
{
 
   # Add directories
  systemd.tmpfiles.rules = [
    "d ${homeDir}/dockge/config 0755 ${dockgeUser} users - -"
    "d ${homeDir}/dockge/data   0755 ${dockgeUser} users - -"
    "d ${homeDir}/dockge/stacks 0755 ${dockgeUser} users - -"
  ];

  # User service (systemd --user)
  systemd.user.services.dockge = {
    description = "Dockge (Podman rootless)";
    serviceConfig = {
      ExecStart = "${pkgs.podman}/bin/podman run --name dockge \
        -p 5001:5001 \
        -v ${homeDir}/dockge/config:/app/config \
        -v ${homeDir}/dockge/data:/app/data \
        -v ${homeDir}/dockge/stacks:/opt/stacks \
        -v /run/user/${toString config.users.users.${dockgeUser}.uid}/podman/podman.sock:/var/run/docker.sock \
        docker.io/louislam/dockge:latest";

      Restart = "always";
    };
    wantedBy = [ "default.target" ];
  };
}
