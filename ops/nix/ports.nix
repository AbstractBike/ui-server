# Port registry — single source of truth.
# All other files reference cfg.ports.* — never hardcode ports.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.ports = {
    http    = lib.mkOption { type = lib.types.port; default = 8080;  description = "HTTP API port"; };
    metrics = lib.mkOption { type = lib.types.port; default = 9090;  description = "Prometheus metrics port"; };
    health  = lib.mkOption { type = lib.types.port; default = 8080;  description = "Health probe port (often same as http)"; };
    # grpc  = lib.mkOption { type = lib.types.port; default = 50051; description = "gRPC port"; };
    # admin = lib.mkOption { type = lib.types.port; default = 8081;  description = "Admin API port"; };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.ports.http ];
    # add cfg.ports.metrics if metrics are scraped externally
  };
}
