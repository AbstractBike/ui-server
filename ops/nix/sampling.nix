# Trace sampling rules via OTEL SDK env vars.
# Works with traces.nix — requires traces.enable = true.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.sampling = {
    strategy = lib.mkOption {
      type    = lib.types.enum [ "always_on" "always_off" "probabilistic" "rate_limiting" ];
      default = "probabilistic";
    };
    rate = lib.mkOption { type = lib.types.float; default = 0.1; description = "Sample rate 0.0-1.0 (probabilistic only)"; };
  };

  config = lib.mkIf (cfg.enable && cfg.traces.enable) {
    systemd.services.ui-server.environment = {
      OTEL_TRACES_SAMPLER     = if cfg.sampling.strategy == "probabilistic"
                                then "parentbased_traceidratio"
                                else cfg.sampling.strategy;
      OTEL_TRACES_SAMPLER_ARG = toString cfg.sampling.rate;
    };
  };
}
