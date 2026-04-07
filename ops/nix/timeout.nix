# Timeout policies for nginx proxy + systemd service.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.timeout = {
    proxyRead    = lib.mkOption { type = lib.types.int; default = 60;  description = "nginx proxy_read_timeout (seconds)"; };
    proxyConnect = lib.mkOption { type = lib.types.int; default = 5;   description = "nginx proxy_connect_timeout (seconds)"; };
    start        = lib.mkOption { type = lib.types.str; default = "30s"; description = "systemd TimeoutStartSec"; };
    stop         = lib.mkOption { type = lib.types.str; default = "10s"; description = "systemd TimeoutStopSec"; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ui-server.serviceConfig = {
      TimeoutStartSec = cfg.timeout.start;
      TimeoutStopSec  = cfg.timeout.stop;
    };
  };
}
