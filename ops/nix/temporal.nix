# Temporal worker config — only for services that embed a Temporal worker.
# Most forks (adguardhome, grafana, otelcol, etc.) do NOT need this file.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.temporal = {
    worker.enable  = lib.mkOption { type = lib.types.bool; default = false; };
    worker.package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = null; description = "Worker binary package (defaults to cfg.package)"; };
    taskQueue  = lib.mkOption { type = lib.types.str; default = "ui-server"; };
    namespace  = lib.mkOption { type = lib.types.str; default = "default"; };
    host       = lib.mkOption { type = lib.types.str; default = "temporal.pin:7233"; };
    schedules  = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = []; description = "Temporal Schedule definitions to register at startup"; };
  };

  config = lib.mkIf (cfg.enable && cfg.temporal.worker.enable) {
    systemd.services.ui-server-worker = {
      description = "ui-server Temporal worker";
      after       = [ "network-online.target" "ui-server.service" ];
      wantedBy    = [ "multi-user.target" ];
      environment = {
        TEMPORAL_HOST       = cfg.temporal.host;
        TEMPORAL_NAMESPACE  = cfg.temporal.namespace;
        TEMPORAL_TASK_QUEUE = cfg.temporal.taskQueue;
      };
      serviceConfig = {
        User       = cfg.user;
        ExecStart  = "${if cfg.temporal.worker.package != null then cfg.temporal.worker.package else cfg.package}/bin/ui-server-worker";
        Restart    = "always";
        RestartSec = "5s";
      };
    };
  };
}
