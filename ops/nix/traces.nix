# OTEL tracing env vars injected into the service process.
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.traces = {
    enable      = lib.mkOption { type = lib.types.bool; default = false; };
    endpoint    = lib.mkOption { type = lib.types.str; default = "http://otelcol.pin:4317"; };
    serviceName = lib.mkOption { type = lib.types.str; description = "OTEL service.name attribute"; };
    protocol    = lib.mkOption { type = lib.types.enum [ "grpc" "http" ]; default = "grpc"; };
  };

  config = lib.mkIf (cfg.enable && cfg.traces.enable) {
    pinpkgs.ui-server.traces.serviceName = lib.mkDefault "ui-server";
    systemd.services.ui-server.environment = {
      OTEL_TRACES_EXPORTER          = "otlp";
      OTEL_EXPORTER_OTLP_ENDPOINT   = cfg.traces.endpoint;
      OTEL_EXPORTER_OTLP_PROTOCOL   = if cfg.traces.protocol == "grpc" then "grpc" else "http/protobuf";
      OTEL_SERVICE_NAME             = cfg.traces.serviceName;
    };
  };
}
