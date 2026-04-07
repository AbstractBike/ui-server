# VictoriaMetrics alerting rules (vmalert format).
# Rules are also defined in ops/obs/alerts.yaml — this file makes them configurable via Nix.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.alerts.rules = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name        = lib.mkOption { type = lib.types.str; };
        expr        = lib.mkOption { type = lib.types.str; description = "MetricsQL expression"; };
        for         = lib.mkOption { type = lib.types.str; default = "5m"; };
        severity    = lib.mkOption { type = lib.types.enum [ "critical" "warning" "info" ]; default = "warning"; };
        annotations = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
        labels      = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
      };
    });
    default     = [];
    description = "Alerting rules loaded by vmalert. Also write to ops/obs/alerts.yaml for version-controlled static rules.";
  };

  # Rules are written to a YAML file consumed by vmalert's -rule flag
  # Integration with catalog/nix/vmalert.nix happens at the host level
}
