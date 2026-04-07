# Non-secret environment variables injected into the systemd service.
# For secrets, use secrets.nix with sops-nix.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.env = lib.mkOption {
    type        = lib.types.attrsOf lib.types.str;
    default     = {};
    description = "Non-secret environment variables for the service.";
    example     = { LOG_LEVEL = "info"; TZ = "UTC"; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ui-server.environment = {
      LOG_LEVEL        = "info";
      OTEL_SERVICE_NAME = "ui-server";
    } // cfg.env;
  };
}
