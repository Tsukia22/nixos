{ config, lib, pkgs }:
let
  ### Imports

  curl = "${pkgs.curl}/bin/curl";
  echo = "${pkgs.coreutils}/bin/echo";
  runuser = "${pkgs.util-linux}/bin/runuser";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
  ssh = "${pkgs.openssh}/bin/ssh";
  #sleep = "${pkgs.coreutils}/bin/sleep";
  
  ### Helper functions

  hello = { message }: ''${echo} "Hello ${message}"'';

  dateTime = ''${echo} $(date +"%Y-%m-%d %H:%M:%S")'';

  url = { unit, suffix }: ''http://${config.host.notify-target}:25558/ping/${config.host.notify-key}/"$HOSTNAME"${if unit != "" then "-${unit}" else ""}${suffix}?create=1'';
  # TODO: temp retry 0
  notify = { unit, suffix }: ''${curl} -m 5 --retry 0 ${url { unit = unit; suffix = suffix; }} || true'';
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

  # TODO: convert ScriptBin to Script and implement in service

  snapshot-loop = pkgs.writeShellScriptBin "snapshot-loop" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: p: ''
        ${echo} "Creating snapshot of ${name}"
        btrfs subvolume snapshot -r ${p.from} ${p.to}/${name}-$(date +%Y%m%d)
        ${echo} "Snapshot created"
      '') config.host.snapshots
    )
  );

  backup-loop = pkgs.writeShellScriptBin "backup-loop" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: p: ''
        ${echo} "Creating remote backup: sending ${name} to ${p.remote}"
        PREV=$(ls ${p.from} | sort | tail -2 | head -1)
        CURR=$(ls ${p.from} | sort | tail -1)
        ${echo} "$PREV -> $CURR"
        ${btrfs} send -p ${p.from}/$PREV ${p.from}/$CURR | ${ssh} $HOSTNAME@${p.remote} -p 1993 "sudo btrfs receive ${p.to}"
        ${echo} "Backup ${name} complete."
      '') config.host.backups
    )
  );

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

  ### For testing

  check-url = pkgs.writeShellScriptBin "check-url" ''
    ${echo} ${url { unit = "check-url"; suffix = "suffix"; }}
  '';

in
{
  inherit dateTime notify notifyPing notifyStart notifyFail notifyOnStop writeRunningStopContainers restartContainersInRunning manual-shutdown manual-reboot manual-stop-containers check-url snapshot-loop backup-loop;
}