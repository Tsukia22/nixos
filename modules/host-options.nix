{ lib, ... }:
{
  # Host options/configs
  options.host = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The primary domain for this host";
    };
    notify-target = lib.mkOption {
      type = lib.types.str;
      description = "The notification target IP or domain";
    };
    notify-key = lib.mkOption {
      type = lib.types.str;
      description = "The notification identifier";
    };
    snapshots = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          from = lib.mkOption {
            type        = lib.types.str;
            description = "Source path";
          };
          to = lib.mkOption {
            type        = lib.types.str;
            description = "Destination path";
          };
        };
      });
      default     = {};
      description = "Snapshot configuration";
    };
    backups = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          remote = lib.mkOption {
            type        = lib.types.str;
            description = "The backup host IP or domain";
          };
          from = lib.mkOption {
            type        = lib.types.str;
            description = "Source path";
          };
          to = lib.mkOption {
            type        = lib.types.str;
            description = "Destination path";
          };
        };
      });
      default     = {};
      description = "Backup configuration";
    };
  };
}