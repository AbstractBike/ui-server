# Build derivation for ui-server (temporalio/ui-server fork).
# Receives `src` as argument — does not fetch internally.
{
  lib,
  buildGoModule,
  src,
}:
buildGoModule {
  pname = "ui-server";
  version = "0-pinpkgs";
  inherit src;

  modRoot = ".";
  subPackages = [ "cmd/server" ];

  vendorHash = "sha256-fKf039QYD7WgWT3JYr7ZaMyYSjUsY4DRo/Ral1Bu9Xw=";

  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  postInstall = ''
    mv $out/bin/server $out/bin/ui-server
  '';

  meta = {
    description = "Temporal UI server (AbstractBike fork)";
    license = lib.licenses.mit;
    mainProgram = "ui-server";
    platforms = [ "x86_64-linux" ];
  };
}
