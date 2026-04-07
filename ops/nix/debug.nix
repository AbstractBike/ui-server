# Debug endpoints grouped under IP allowlist in nginx.
# Disable in production or restrict to 127.0.0.1.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.debug = {
    enable     = lib.mkOption { type = lib.types.bool; default = false; };
    allowedIPs = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "127.0.0.1" ]; };
    endpoints  = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "/debug" ]; };
  };

  config = lib.mkIf (cfg.enable && cfg.debug.enable && cfg.routing.enable) {
    services.nginx.virtualHosts.${cfg.routing.lanDomain}.locations = lib.listToAttrs
      (map (ep: lib.nameValuePair ep {
        proxyPass  = "http://127.0.0.1:${toString cfg.ports.http}${ep}";
        extraConfig = ''
          ${lib.concatMapStrings (ip: "allow ${ip};\n") cfg.debug.allowedIPs}
          deny all;
        '';
      }) cfg.debug.endpoints);
  };
}
