# Profiling endpoints — pprof (Go), async-profiler (JVM), py-spy (Python).
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.profiling = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port   = lib.mkOption { type = lib.types.port; default = 6060; };
    path   = lib.mkOption { type = lib.types.str; default = "/debug/pprof"; };
  };

  config = lib.mkIf (cfg.enable && cfg.profiling.enable) {
    systemd.services.ui-server.environment = {
      # Go: pprof is enabled by importing net/http/pprof
      PPROF_PORT = toString cfg.profiling.port;
      # JVM: set JAVA_TOOL_OPTIONS to attach async-profiler
    };
    # sandbox.nix may need ptrace capability if using continuous profiling
  };
}
