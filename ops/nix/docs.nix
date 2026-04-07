# OpenAPI/Swagger documentation endpoint.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.docs = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    path   = lib.mkOption { type = lib.types.str; default = "/docs"; };
    port   = lib.mkOption { type = lib.types.port; description = "Port serving docs (defaults to http port)"; };
  };

  config = lib.mkIf (cfg.enable && cfg.docs.enable) {
    pinpkgs.ui-server.docs.port = lib.mkDefault cfg.ports.http;
    services.nginx.virtualHosts.${cfg.routing.lanDomain}.locations.${cfg.docs.path} = {
      proxyPass = "http://127.0.0.1:${toString cfg.docs.port}${cfg.docs.path}";
    };
  };
}
