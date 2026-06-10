{ config, lib, pkgs }:
let
  ### Imports

  curl = "${pkgs.curl}/bin/curl";
  echo = "${pkgs.coreutils}/bin/echo";
  runuser = "${pkgs.util-linux}/bin/runuser";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
  ssh = "${pkgs.openssh}/bin/ssh";
  sleep = "${pkgs.coreutils}/bin/sleep";
  ping = "${pkgs.iputils}/bin/ping";
  
  ### Helper functions

  hello = { message }: ''${echo} "Hello ${message}"'';

  dateTime = ''${echo} $(date +"%Y-%m-%d %H:%M:%S")'';

  url = { unit, suffix }: ''http://${config.host.notify-target}:25558/ping/${config.host.notify-key}/"$HOSTNAME"${if unit != "" then "-${unit}" else ""}${suffix}?create=1'';
  notify = { unit, suffix }: ''${curl} -m 10 --retry 3 ${url { unit = unit; suffix = suffix; }} || true'';
  notifyPing = { unit }: ''${notify { unit = unit; suffix = ""; }}'';
  notifyFail = { unit }: ''${notify { unit = unit; suffix = "/fail"; }}'';
  notifyStart = { unit }: ''${notify { unit = unit; suffix = "/start"; }}'';

  ### Main functions

  notifyOnStop = { unit }: pkgs.writeShellScript "notifyOnStop-${unit}" ''
    if [ "$SERVICE_RESULT" == "success" ]; then
      ${notifyPing { unit = unit; }}
    else
      ${notifyFail { unit = unit; }}
    fi
  '';

  snapshotLoop = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: p: ''
      ${echo} "Creating snapshot of ${name}"
      btrfs subvolume snapshot -r ${p.from} ${p.to}/${name}-$(date +%Y%m%d)
      ${echo} "Snapshot created"
    '') config.host.snapshots
  );

  # TODO: Add some kind of btrfs send confirmation the snapshot is fully received.
  backupLoop = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: p: ''
      ${echo} "Creating remote backup: sending ${name} to ${p.remote}"
      PREV=$(ls ${p.from} | sort | tail -2 | head -1)
      CURR=$(ls ${p.from} | sort | tail -1)
      ${echo} "$PREV -> $CURR"
      ${btrfs} send -p ${p.from}/$PREV ${p.from}/$CURR | ${ssh} $HOSTNAME@${p.remote} -p 1993 "sudo btrfs receive ${p.to}"
      ${echo} "Backup ${name} complete."
    '') config.host.backups
  );

  pingLoop = ''
    i=0
    until ${ping} -c1 -W2 ${config.host.notify-target} > /dev/null 2>&1; do
      ${sleep} 5
      i=$((i+1))
      [ $i -ge 24 ] && exit 1
    done
  '';

  writeRunningStopContainers = ''
    set -eu
    ${dateTime}

    ${echo} "Storing currently running container ids"
    ${runuser} -l kami -c 'podman ps -q > /home/kami/running'

    ${echo} "Stopping all containers"
    ${dateTime}
    ${runuser} -l kami -c 'podman stop --all --timeout 60'
    ${dateTime}
    ${echo} "Done stopping all containers"
  '';

  restartContainersInRunning = ''
    set -eu
    ${echo} "Starting containers in running"
    ${dateTime}
    ${runuser} -l kami -c 'xargs -r -n 1 podman restart < /home/kami/running'
    ${dateTime}
    ${echo} "Done starting containers in running"
  '';

  ### CLI scripts

  manual-shutdown = pkgs.writeShellScriptBin "manual-shutdown" ''
    ${echo} "Manual shutdown!"
    ${writeRunningStopContainers}
    shutdown now
  '';

  manual-reboot = pkgs.writeShellScriptBin "manual-reboot" ''
    ${echo} "Manual reboot!"
    ${writeRunningStopContainers}
    shutdown -r now
  '';

  manual-stop-containers = pkgs.writeShellScriptBin "manual-stop-containers" ''
    ${echo} "Stopping containers"
    ${writeRunningStopContainers}
    ${echo} "Stopped containers"
  '';

  # Hard-coded manual backup script
  manual-backup = pkgs.writeShellScriptBin "manual-backup" ''
    if [[ -z "$1" ]] || [[ -z "$2" ]]; then
      ${echo} "Usage: manual-backup <name> <path>"
      ${echo} "manual-backup volumes /home/kami/.local/share/containers/storage/volumes"
      ${echo} "manual-backup immich /home/kami/stacks/immich/library/library"
      exit 1
    fi
    set -eu
    NAME="$1"
    SOURCE="$2"
    ${echo} $(date +"%Y-%m-%d %H:%M:%S")
    ${echo} "Creating snapshot of $NAME"
    btrfs subvolume snapshot -r $SOURCE /var/snapshots/$NAME/$NAME-$(date +%Y%m%d%H%M%S)
    ${echo} "Snapshot created"
    ${echo} "Creating remote backup: sending $NAME to 10.100.0.2"
    PREV=$(ls /var/snapshots/$NAME/ | sort | tail -2 | head -1)
    CURR=$(ls /var/snapshots/$NAME/ | sort | tail -1)
    ${echo} "$PREV -> $CURR"
    ${btrfs} send -p /var/snapshots/$NAME/$PREV /var/snapshots/$NAME/$CURR | ssh $HOSTNAME@10.100.0.2 -p 1993 "sudo btrfs receive /mnt/hdd/$HOSTNAME/backups/$NAME"
    ${echo} "Backup $NAME complete."
  '';

  ### For testing

  check-url = pkgs.writeShellScriptBin "check-url" ''
    ${echo} ${url { unit = "check-url"; suffix = "suffix"; }}
  '';

in
{
  inherit dateTime notify notifyPing notifyStart notifyFail notifyOnStop pingLoop snapshotLoop backupLoop writeRunningStopContainers restartContainersInRunning manual-shutdown manual-reboot manual-stop-containers check-url manual-backup;
}