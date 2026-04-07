# Self-imposed rate limits for external APIs consumed by this service.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.quota.apis = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        requestsPerDay    = lib.mkOption { type = lib.types.int; default = 1000; };
        requestsPerMinute = lib.mkOption { type = lib.types.int; default = 60; };
      };
    });
    default     = {};
    description = "Rate limits for external APIs consumed. Generated as env vars.";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ui-server.environment = lib.mkMerge (lib.mapAttrsToList (name: q: {
      "${lib.toUpper name}_QUOTA_PER_DAY"    = toString q.requestsPerDay;
      "${lib.toUpper name}_QUOTA_PER_MINUTE" = toString q.requestsPerMinute;
    }) cfg.quota.apis);
  };
}
