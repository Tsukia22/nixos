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
  slug_prefix = "$HOSTNAME";
  
  ### Helper functions

  hello = { message }: ''${echo} "Hello ${message}"'';

  dateTime = ''${echo} $(date +"%Y-%m-%d %H:%M:%S")'';

  notify = { target, message, unit }: ''
    URL=http://${target}:25558/ping/${ping-key}/${slug_prefix}?create=1
    ${curl} -m 5 --retry 2 --data-raw "${message}" $URL
  '';

  notifyFail = { target, message, unit }: ''
    URL=http://${target}:25558/ping/${ping-key}/${slug_prefix}/fail?create=1
    ${curl} -m 5 --retry 2 --data-raw "${message}" $URL
  '';

  notifyPingStart = { target, unit }: ''
    URL=http://${target}:25558/ping/${ping-key}/${slug_prefix}-${unit}/start?create=1
    ${curl} -m 5 --retry 2 $URL
  '';

  notifyPing = { target, unit }: ''
    URL=http://${target}:25558/ping/${ping-key}/${slug_prefix}-${unit}?create=1
    ${curl} -m 5 --retry 2 $URL
  '';

  ### Main functions
  $SERVICE_RESULT
  makeExecStopPost = { target, unit, result }: pkgs.writeShellScript "notify-${unit}" ''
    if [ ${result} == "success" ]; then
      MESSAGE="Service finished with: ${result}"
      ${notify { target = target; message = "$MESSAGE"; unit = unit; }}
    else
      LOGS=$(${journalctl} -u ${unit}.service -n 20 --no-pager)
      MESSAGE="${unit} failed: ${result} \n $LOGS"
      ${notifyFail { target = target; message = "$MESSAGE"; unit = unit; }}
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
  inherit dateTime notify notifyPing notifyPingStart makeExecStopPost writeRunningStopContainers restartContainersInRunning;
  environment.systemPackages = [ manual-shutdown manual-reboot ];
}