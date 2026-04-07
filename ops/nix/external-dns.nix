# External DNS record management for public-facing domains.
# Provider-agnostic: works with Cloudflare, Route53, Hetzner DNS, etc.
# Declares the desired public DNS records; the catalog/networking/external-dns.nix
# host module reconciles them against the configured provider via external-dns or
# Terraform/tofu runs triggered by the deploy Saga.
#
# Defaults: disabled (internal-only service).
{ lib, config, ... }:
let cfg = config.pinpkgs.ui-server; in {
  options.pinpkgs.ui-server.externalDns = {
    enable = lib.mkEnableOption "public external DNS records for ui-server";

    domain = lib.mkOption {
      type        = lib.types.str;
      default     = "ui-server.example.com";
      description = "Public FQDN for ui-server. Provider resolves this to the egress IP or tunnel.";
    };

    proxied = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = ''
        Whether traffic is proxied through the DNS provider (e.g. Cloudflare orange-cloud).
        False = DNS-only / bare IP record.
      '';
    };

    ttl = lib.mkOption {
      type        = lib.types.int;
      default     = 1;
      description = "TTL in seconds. 1 = auto/provider default (Cloudflare proxied ignores TTL).";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.externalDns.enable) {
    # Record reconciliation is driven externally (external-dns controller or tofu).
    # This module exposes the desired state so the catalog can read it.
  };
}
