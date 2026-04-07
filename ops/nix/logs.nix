# Log shipping — journald → Vector → VictoriaLogs.
# For journald-based services this is automatic via otelcol journald receiver.
# Only populate for file-based log sources.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.logs = {
    format       = lib.mkOption { type = lib.types.enum [ "json" "text" ]; default = "json"; };
    journaldUnit = lib.mkOption { type = lib.types.str; default = "ui-server.service"; description = "systemd unit to collect logs from"; };
    filePaths    = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Additional log file paths (if not journald)"; };
    fields       = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = { service = "ui-server"; }; description = "Extra fields added to every log record"; };
  };

  config = lib.mkIf cfg.enable {
    # journald is picked up automatically by otelcol
    # For file sources, add Vector config in ops/obs/vector.yaml
  };
}
