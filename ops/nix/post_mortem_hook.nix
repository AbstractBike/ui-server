# Script that runs when the service fails (forensics, capture state, notify).
# Triggered via systemd OnFailure= — runs in a separate unit.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.hooks.postFailure = {
    script        = lib.mkOption { type = lib.types.lines; default = ""; description = "Shell script to run on service failure"; };
    notifyChannel = lib.mkOption { type = lib.types.str; default = ""; description = "Telegram/Slack channel for failure notification"; };
  };

  config = lib.mkIf (cfg.enable && cfg.hooks.postFailure.script != "") {
    systemd.services.ui-server-post-mortem = {
      description = "ui-server post-mortem forensics";
      serviceConfig = {
        Type     = "oneshot";
        User     = cfg.user;
        ExecStart = pkgs.writeShellScript "ui-server-post-mortem" cfg.hooks.postFailure.script;
      };
    };
    systemd.services.ui-server.unitConfig.OnFailure = "ui-server-post-mortem.service";
  };
}
