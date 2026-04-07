# Authentication for the service endpoint (nginx level).
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.auth = {
    method = lib.mkOption {
      type        = lib.types.enum [ "none" "basic" "sso" ];
      default     = "none";
      description = "Authentication method for the nginx vhost";
    };
    htpasswdSecret = lib.mkOption {
      type        = lib.types.str;
      default     = "";
      description = "SOPS secret key for the htpasswd file (basic auth only)";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.auth.method == "basic") {
    services.nginx.virtualHosts.${cfg.routing.lanDomain}.basicAuthFile =
      config.sops.secrets.${cfg.auth.htpasswdSecret}.path;
  };
}
