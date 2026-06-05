{ pkgs }:
let
  curl = "${pkgs.curl}/bin/curl";
  echo = "${pkgs.coreutils}/bin/echo";
  ping-key = "xfvqwclbw6d3h1pxaaog2w";
  slug = "$HOSTNAME";
in
{
  notify = { message, target }: ''
    URL=http://${target}:25558/ping/${ping-key}/${slug}?create=1
    ${curl} -m 5 --retry 2 --data-raw "${message}" $URL
  '';
  notifyFail = { message, target }: ''
    URL=http://${target}:25558/ping/${ping-key}/${slug}/fail?create=1
    ${curl} -m 5 --retry 2 --data-raw "${message}" $URL
  '';
  hello = { message }: ''
    ${echo} "Hello ${message}"
  '';
}