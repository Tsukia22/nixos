{ pkgs }:
let
  curl = "${pkgs.curl}/bin/curl";
  echo = "${pkgs.coreutils}/bin/echo";
in
{
  notifyFail = { message, target }: ''
    PING_KEY=xfvqwclbw6d3h1pxaaog2w
    SLUG=$HOSTNAME
    URL=http://${target}:25558/ping/$PING_KEY/$SLUG?create=1
    ${curl} -m 5 --retry 2 --data-raw "${message}" $URL
  '';
  hello = { message }: ''
    ${echo} "Hello ${message}"
  '';
}