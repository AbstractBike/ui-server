# Rate limiting via nginx limit_req.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.ratelimit = {
    enable            = lib.mkOption { type = lib.types.bool; default = false; };
    requestsPerSecond = lib.mkOption { type = lib.types.int; default = 10; };
    burstSize         = lib.mkOption { type = lib.types.int; default = 20; };
  };

  config = lib.mkIf (cfg.enable && cfg.ratelimit.enable) {
    services.nginx.virtualHosts.${cfg.routing.lanDomain}.extraConfig = ''
      limit_req_zone $binary_remote_addr zone=ui-server:10m rate=${toString cfg.ratelimit.requestsPerSecond}r/s;
      limit_req zone=ui-server burst=${toString cfg.ratelimit.burstSize} nodelay;
      limit_req_status 429;
    '';
  };
}
