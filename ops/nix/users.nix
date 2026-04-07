# System user and group for the service process.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server = {
    user  = lib.mkOption { type = lib.types.str; default = "ui-server"; description = "System user for the service"; };
    group = lib.mkOption { type = lib.types.str; default = "ui-server"; description = "System group for the service"; };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group        = cfg.group;
      description  = "ui-server service user";
    };
    users.groups.${cfg.group} = {};
  };
}
