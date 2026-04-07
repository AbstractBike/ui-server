# Prometheus scrape config — consumed by otelcol/nixos.nix extraScrapeConfigs.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.metrics = {
    path     = lib.mkOption { type = lib.types.str; default = "/metrics"; };
    port     = lib.mkOption { type = lib.types.port; description = "Metrics scrape port"; };
    interval = lib.mkOption { type = lib.types.str; default = "15s"; };
    labels   = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = { service = "ui-server"; }; };
  };

  config = lib.mkIf cfg.enable {
    pinpkgs.ui-server.metrics.port = lib.mkDefault cfg.ports.metrics;

    # Adds this service to otelcol's scrape list
    # services.otelcol-obs.extraScrapeConfigs = [{
    #   job_name       = "ui-server";
    #   scrape_interval = cfg.metrics.interval;
    #   static_configs  = [{ targets = [ "127.0.0.1:${toString cfg.metrics.port}" ]; labels = cfg.metrics.labels; }];
    #   metrics_path    = cfg.metrics.path;
    # }];
  };
}
