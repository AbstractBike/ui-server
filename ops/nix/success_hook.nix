# Script that runs after the service starts successfully.
# Use for smoke tests, cache invalidation, Temporal workflow signals.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.hooks.postSuccess = {
    script  = lib.mkOption { type = lib.types.lines; default = ""; description = "Shell script to run after successful start"; };
    timeout = lib.mkOption { type = lib.types.str; default = "10s"; };
  };

  config = lib.mkIf (cfg.enable && cfg.hooks.postSuccess.script != "") {
    systemd.services.ui-server.serviceConfig.ExecStartPost =
      pkgs.writeShellScript "ui-server-success-hook" cfg.hooks.postSuccess.script;
  };
}
