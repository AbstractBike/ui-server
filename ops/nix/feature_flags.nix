# Feature toggles injected as FEATURE_<NAME>=true/false env vars.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.featureFlags = lib.mkOption {
    type        = lib.types.attrsOf lib.types.bool;
    default     = {};
    description = "Feature flags injected as FEATURE_<NAME>=true/false environment variables.";
    example     = { new_dashboard = true; legacy_api = false; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ui-server.environment = lib.mapAttrs'
      (name: val: lib.nameValuePair
        "FEATURE_${lib.toUpper (builtins.replaceStrings ["-"] ["_"] name)}"
        (if val then "true" else "false"))
      cfg.featureFlags;
  };
}
