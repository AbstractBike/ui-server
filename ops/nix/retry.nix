# Retry policies for nginx upstream (proxy_next_upstream).
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.retry = {
    enable     = lib.mkOption { type = lib.types.bool; default = false; };
    attempts   = lib.mkOption { type = lib.types.int; default = 1; };
    conditions = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "error" "timeout" ]; };
  };

  config = lib.mkIf (cfg.enable && cfg.retry.enable) {
    services.nginx.virtualHosts.${cfg.routing.lanDomain}.locations."/".extraConfig = ''
      proxy_next_upstream ${lib.concatStringsSep " " cfg.retry.conditions};
      proxy_next_upstream_tries ${toString cfg.retry.attempts};
    '';
  };
}
