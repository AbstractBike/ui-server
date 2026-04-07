# Grafana dashboard defined as Nix attrset — generates JSON at build time.
# References cfg.ports.* and cfg.metrics.* so the dashboard stays in sync with config.
# Also see ops/obs/dashboard.json for the static version.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.dashboard = {
    enable     = lib.mkOption { type = lib.types.bool; default = true; };
    datasource = lib.mkOption { type = lib.types.str; default = "VictoriaMetrics"; };
    folder     = lib.mkOption { type = lib.types.str; default = "services"; };
  };

  config = lib.mkIf (cfg.enable && cfg.dashboard.enable) {
    # Dashboard provisioned via Grafana's foldersFromFilesStructure provisioner
    # The dashboard JSON is generated from ops/obs/dashboard.json or compiled from Jsonnet
    # services.grafana-obs.extraDashboardPaths = [ ... ];
  };
}
