{ pkgs }:
let
  helper = import ./helper.nix { inherit pkgs; };
in
{
  makeExecStopPost = { unit, target }: pkgs.writeShellScript "notify-fail-${unit}" ''
    if [ "$SERVICE_RESULT" == "success" ]; then
      MESSAGE="Service finished with: $SERVICE_RESULT"
      ${helper.notify { message = "$MESSAGE"; target = target; }}
    else
      LOGS=$(journalctl -u ${unit}.service -n 20 --no-pager)
      MESSAGE="Service failed with: $SERVICE_RESULT\n$LOGS"
      ${helper.notifyFail { message = "$MESSAGE"; target = target; }}
    fi
  '';
}