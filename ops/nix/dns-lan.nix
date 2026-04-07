# Internal DNS entries for .pin domains.
# Consumed by AdGuardHome or CoreDNS rewrite rules in catalog/networking.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.dns = {
    domain  = lib.mkOption { type = lib.types.str; default = "ui-server.pin"; description = "Primary internal domain"; };
    aliases = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Additional DNS aliases"; };
  };

  config = lib.mkIf cfg.enable {
    # DNS rewrite rules are configured at the host level in catalog/networking/adguardhome.nix
    # This module documents the desired domain — the host wires it up.
  };
}
