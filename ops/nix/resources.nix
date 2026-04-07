# CPU/memory/task limits for the systemd service.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.resources = {
    memoryMax = lib.mkOption { type = lib.types.str; default = "512M"; description = "Hard memory limit (OOM kill above this)"; };
    memoryHigh = lib.mkOption { type = lib.types.str; default = "400M"; description = "Soft memory limit (throttled above this)"; };
    cpuQuota  = lib.mkOption { type = lib.types.str; default = "100%"; description = "CPU quota (200% = 2 cores)"; };
    tasksMax  = lib.mkOption { type = lib.types.int; default = 256;    description = "Max number of tasks/threads"; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ui-server.serviceConfig = {
      MemoryMax  = cfg.resources.memoryMax;
      MemoryHigh = cfg.resources.memoryHigh;
      CPUQuota   = cfg.resources.cpuQuota;
      TasksMax   = cfg.resources.tasksMax;
    };
  };
}
