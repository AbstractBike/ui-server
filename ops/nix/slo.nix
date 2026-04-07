# SLO definitions + error budget as vmalert recording rules.
# errorQuery / totalQuery are MetricsQL expressions.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.slo.objectives = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name       = lib.mkOption { type = lib.types.str; };
        target     = lib.mkOption { type = lib.types.float; default = 0.999; description = "e.g. 0.999 = 99.9%"; };
        window     = lib.mkOption { type = lib.types.str; default = "30d"; };
        errorQuery = lib.mkOption { type = lib.types.str; description = "MetricsQL: count of errors"; };
        totalQuery = lib.mkOption { type = lib.types.str; description = "MetricsQL: total requests"; };
      };
    });
    default     = [];
    description = "SLO objectives. Each generates vmalert recording rules for burn rate.";
  };

  # Recording rules are written to ops/obs/alerts.yaml via dashboard.nix
  # and loaded by vmalert via catalog/nix/vmalert.nix
}
