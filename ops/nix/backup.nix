# Restic backup jobs for service state directories.
# Requires restic-server to be running (catalog/storage or contabo).
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.backup = {
    enable          = lib.mkOption { type = lib.types.bool; default = false; };
    schedule        = lib.mkOption { type = lib.types.str; default = "daily"; description = "systemd OnCalendar expression"; };
    paths           = lib.mkOption { type = lib.types.listOf lib.types.str; description = "Paths to back up"; };
    repository      = lib.mkOption { type = lib.types.str; default = "rest:https://backup.pin/ui-server"; };
    passwordSecret  = lib.mkOption { type = lib.types.str; default = "restic-password"; description = "SOPS secret key for restic password"; };
    retentionPolicy = lib.mkOption { type = lib.types.str; default = "--keep-daily 7 --keep-weekly 4 --keep-monthly 6"; };
  };

  config = lib.mkIf (cfg.enable && cfg.backup.enable) {
    pinpkgs.ui-server.backup.paths = lib.mkDefault cfg.storage.stateDirs;

    services.restic.backups.ui-server = {
      timerConfig.OnCalendar = cfg.backup.schedule;
      timerConfig.Persistent = true;
      paths        = cfg.backup.paths;
      repository   = cfg.backup.repository;
      passwordFile = config.sops.secrets.${cfg.backup.passwordSecret}.path;
      pruneOpts    = lib.splitString " " cfg.backup.retentionPolicy;
    };
  };
}
