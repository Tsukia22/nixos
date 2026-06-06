{ config, pkgs }:
let
  ### Imports

  curl = "${pkgs.curl}/bin/curl";
  echo = "${pkgs.coreutils}/bin/echo";
  runuser = "${pkgs.util-linux}/bin/runuser";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  #sleep = "${pkgs.coreutils}/bin/sleep";

  ### Constants

  ping-key = "xfvqwclbw6d3h1pxaaog2w";
  
  ### Helper functions

  hello = { message }: ''${echo} "Hello ${message}"'';

  dateTime = ''${echo} $(date +"%Y-%m-%d %H:%M:%S")'';

  url = { unit, suffix }: ''http://${config.host.notify-target}:25558/ping/${ping-key}/"$HOSTNAME"${if unit != "" then "-${unit}" else ""}${suffix}?create=1'';
  # TODO: temp retry 0
  notify = { message, unit }: ''${curl} -m 5 --retry 0 --data-raw ${message} ${url { unit = unit; suffix = ""; }}'';
  notifyFail = { message, unit }: ''${curl} -m 5 --retry 0 --data-raw ${message} ${url { unit = unit; suffix = "/fail"; }}'';
  notifyPingStart = { unit }: ''${curl} -m 5 --retry 0 ${url { unit = unit; suffix = "/start"; }}'';
  notifyPing = { unit }: ''${curl} -m 5 --retry 0 ${url { unit = unit; suffix = ""; }}'';

  ### Main functions

  notifyOnStop = { unit }: pkgs.writeShellScript "notifyOnStop-${unit}" ''
    if [ "$SERVICE_RESULT" == "success" ]; then
      MESSAGE="Service finished with: $SERVICE_RESULT"
      ${notify { message = "$MESSAGE"; unit = unit; }}
    else
      LOGS=$(${journalctl} -u ${unit} -n 20 --no-pager)
      MESSAGE="${unit} failed: $SERVICE_RESULT \n $LOGS"
      ${notifyFail { message = "$MESSAGE"; unit = unit; }}
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

  check-url = pkgs.writeShellScriptBin "check-url" ''
    ${echo} ${url { unit = "check-url"; suffix = "suffix"; }}
  '';
in
{
  inherit dateTime notify notifyPing notifyPingStart notifyOnStop writeRunningStopContainers restartContainersInRunning manual-shutdown manual-reboot check-url;
}