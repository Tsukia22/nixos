{ pkgs }:
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

  url = { unit, suffix }: "http://${config.host.notify-target}:25558/ping/${ping-key}/"$HOSTNAME"${if unit != "" then "-${unit}" else ""}${suffix}?create=1";

  notify = { message, unit }: '' ${curl} -m 5 --retry 2 --data-raw "${message}" ${url { unit = unit; suffix = "" }} '';
  notifyFail = { message, unit }: '' ${curl} -m 5 --retry 2 --data-raw "${message}" ${url { unit = unit; suffix = "/fail" }} '';
  notifyPingStart = { unit }: '' ${curl} -m 5 --retry 2 ${url { unit = unit; suffix = "/start" }} '';
  notifyPing = { unit }: '' ${curl} -m 5 --retry 2 ${url { unit = unit; suffix = "" }} '';

  ### Main functions

  notifyOnStop = pkgs.writeShellScript "notifyOnStop" ''
    UNIT="$1"
    if [ $RESULT == "success" ]; then
      MESSAGE="Service finished with: $SERVICE_RESULT"
      ${notify { target = target; message = "$MESSAGE"; unit = "$UNIT"; }}
    else
      LOGS=$(${journalctl} -u $UNIT -n 20 --no-pager)
      MESSAGE="$UNIT failed: $SERVICE_RESULT \n $LOGS"
      ${notifyFail { target = target; message = "$MESSAGE"; unit = "$UNIT"; }}
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
in
{
  inherit dateTime notify notifyPing notifyPingStart notifyOnStop writeRunningStopContainers restartContainersInRunning;
  environment.systemPackages = [ manual-shutdown manual-reboot ];
}