# NixOS VM integration tests via pkgs.testers.runNixOSTest.
# Exposed as flake.checks.${system}.test — run with: nix flake check
{ pkgs, ... }:
pkgs.testers.runNixOSTest {
  name = "ui-server-test";

  nodes.machine = { ... }: {
    imports = [ ./nixos.nix ];
    pinpkgs.ui-server.enable = true;
    # override options for testing:
    # pinpkgs.ui-server.storage.stateDir = "/tmp/ui-server-test";
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("ui-server.service")
    machine.wait_for_open_port(8080)
    machine.succeed("curl -sf http://localhost:8080/healthz")
    # add service-specific functional tests here
  '';
}
