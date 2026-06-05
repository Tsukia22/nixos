{ lib, ... }:
{
  # Host options/configs
  options.host = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The primary domain for this host";
    };
    backup-target = lib.mkOption {
      type = lib.types.str;
      description = "The backup target IP or domain";
    };
    notify-target = lib.mkOption {
      type = lib.types.str;
      description = "The notification target IP or domain";
    };
  };
}