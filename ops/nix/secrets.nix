# SOPS-nix secret declarations.
# Mirrors the *-secrets.nix companion pattern in machines/catalog.
# Host secrets.yaml must contain matching keys managed by SOPS+age.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.secrets = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        owner        = lib.mkOption { type = lib.types.str; default = cfg.user; };
        group        = lib.mkOption { type = lib.types.str; default = cfg.group; };
        mode         = lib.mkOption { type = lib.types.str; default = "0400"; };
        restartUnits = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "ui-server.service" ]; };
      };
    });
    default     = {};
    description = "SOPS secrets for this service.";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = lib.mapAttrs (_name: opts: {
      inherit (opts) owner group mode restartUnits;
    }) cfg.secrets;
  };
}
