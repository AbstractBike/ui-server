# L7 routing via nginx virtualhost.
# Uses dns.nix domain + ports.nix http port.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.routing = {
    enable     = lib.mkOption { type = lib.types.bool; default = false; description = "Enable nginx reverse proxy"; };
    lanDomain  = lib.mkOption { type = lib.types.str; description = "nginx server_name"; };
    websockets = lib.mkOption { type = lib.types.bool; default = false; };
    extraLocations = lib.mkOption { type = lib.types.attrsOf lib.types.attrs; default = {}; };
  };

  config = lib.mkIf (cfg.enable && cfg.routing.enable) {
    pinpkgs.ui-server.routing.lanDomain = lib.mkDefault cfg.dns.domain;

    services.nginx.virtualHosts.${cfg.routing.lanDomain} = {
      locations = {
        "/" = {
          proxyPass       = "http://127.0.0.1:${toString cfg.ports.http}";
          proxyWebsockets = cfg.routing.websockets;
          extraConfig     = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
          '';
        };
      } // cfg.routing.extraLocations;
    };
  };
}
