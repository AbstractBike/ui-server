# NixOS module entry point for ui-server
# Replace ui-server with the service name throughout.
# Import only the files you need — remove unused imports.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.ui-server; in {
  imports = [
    ./ports.nix
    ./users.nix
    ./secrets.nix
    ./storage.nix
    ./health.nix
    ./sandbox.nix
    # add as needed:
    # ./env.nix ./resources.nix ./scheduler.nix ./network.nix
    # ./certs.nix ./dns-lan.nix ./external-dns.nix ./routing.nix ./auth.nix
    # ./metrics.nix ./logs.nix ./traces.nix ./sampling.nix
    # ./backup.nix ./temporal.nix ./pre_hook.nix ./success_hook.nix
    # ./alerts.nix ./dashboard.nix
  ];

  options.pinpkgs.ui-server = {
    enable  = lib.mkEnableOption "ui-server AbstractBike fork";
    package = lib.mkOption {
      type        = lib.types.package;
      default     = pkgs.ui-server;
      description = "The ui-server package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ui-server = {
      description = "ui-server service";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network-online.target" ];
      wants       = [ "network-online.target" ];
      serviceConfig = {
        User            = cfg.user;
        Group           = cfg.group;
        ExecStart       = "${cfg.package}/bin/ui-server";
        Restart         = "on-failure";
        RestartSec      = "5s";
        WorkingDirectory = cfg.storage.stateDir;
      };
    };
  };
}
