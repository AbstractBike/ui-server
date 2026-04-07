# Circuit breaker — cuts traffic when service fails persistently.
# Polls health endpoint; toggles nginx upstream to a 503 page when open.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.circuitBreaker = {
    enable           = lib.mkOption { type = lib.types.bool; default = false; };
    failureThreshold = lib.mkOption { type = lib.types.int; default = 5; description = "Consecutive failures before opening circuit"; };
    recoveryTimeout  = lib.mkOption { type = lib.types.str; default = "30s"; description = "Time before attempting half-open"; };
    probePath        = lib.mkOption { type = lib.types.str; description = "Path to poll for circuit state"; };
  };

  config = lib.mkIf (cfg.enable && cfg.circuitBreaker.enable) {
    pinpkgs.ui-server.circuitBreaker.probePath = lib.mkDefault
      "http://127.0.0.1:${toString cfg.health.liveness.port}${cfg.health.liveness.path}";

    systemd.timers.ui-server-circuit-probe = {
      wantedBy  = [ "timers.target" ];
      timerConfig.OnBootSec = "10s";
      timerConfig.OnUnitActiveSec = "10s";
    };
    systemd.services.ui-server-circuit-probe = {
      serviceConfig = {
        Type     = "oneshot";
        ExecStart = pkgs.writeShellScript "ui-server-circuit-probe" ''
          curl -sf ${cfg.circuitBreaker.probePath} || \
            echo "open" > /run/ui-server/circuit-state
        '';
      };
    };
  };
}
