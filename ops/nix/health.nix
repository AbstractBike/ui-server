# Liveness (/healthz) and readiness (/readyz) probes.
# Consumed by: circuit_breaker.nix, catalog.monitor.services, Temporal DeployWorkflow.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.health = {
    liveness = {
      path = lib.mkOption { type = lib.types.str; default = "/healthz"; };
      port = lib.mkOption { type = lib.types.port; description = "Liveness probe port"; };
    };
    readiness = {
      path = lib.mkOption { type = lib.types.str; default = "/readyz"; };
      port = lib.mkOption { type = lib.types.port; description = "Readiness probe port"; };
    };
    startup.delaySecs = lib.mkOption { type = lib.types.int; default = 5; description = "Seconds to wait before first probe"; };
  };

  config = lib.mkIf cfg.enable {
    pinpkgs.ui-server.health.liveness.port  = lib.mkDefault cfg.ports.health;
    pinpkgs.ui-server.health.readiness.port = lib.mkDefault cfg.ports.health;

    # Registers with the centralized health monitoring system
    catalog.monitor.services = [{
      name     = "ui-server";
      type     = "http";
      endpoint = "http://127.0.0.1:${toString cfg.health.liveness.port}${cfg.health.liveness.path}";
    }];
  };
}
