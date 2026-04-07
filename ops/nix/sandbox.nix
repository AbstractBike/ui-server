# Systemd security hardening by level.
# Levels: strict > moderate > permissive
# storage.nix paths are auto-added to ReadWritePaths.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.sandbox = {
    level = lib.mkOption {
      type        = lib.types.enum [ "strict" "moderate" "permissive" ];
      default     = "moderate";
      description = "Hardening level. strict breaks services needing raw sockets or ptrace.";
    };
    extraReadPaths  = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    extraWritePaths = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ui-server.serviceConfig = lib.mkMerge [
      # baseline — all levels
      {
        NoNewPrivileges = true;
        ProtectHome     = true;
        PrivateTmp      = true;
        ReadWritePaths  = cfg.storage.stateDirs ++ cfg.sandbox.extraWritePaths;
        ReadOnlyPaths   = cfg.sandbox.extraReadPaths;
      }
      # moderate+
      (lib.mkIf (cfg.sandbox.level == "moderate" || cfg.sandbox.level == "strict") {
        ProtectSystem      = "strict";
        ProtectKernelTunables = true;
        RestrictNamespaces = true;
      })
      # strict only
      (lib.mkIf (cfg.sandbox.level == "strict") {
        MemoryDenyWriteExecute = true;
        SystemCallFilter       = [ "@system-service" ];
        CapabilityBoundingSet  = "";
      })
    ];
  };
}
