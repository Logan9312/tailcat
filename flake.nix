{
  description = "tailcat: netcat over Tailscale's data plane, without its control plane";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # flakehashes.json is maintained by `make tidy`
        # (tool/updateflakes); do not edit it by hand.
        flakeHashes = builtins.fromJSON (builtins.readFile ./flakehashes.json);
        # Keep the locked nixpkgs toolchain on the crypto/x509 security release.
        go = pkgs.go_1_27.overrideAttrs (finalAttrs: _: {
          version = "1.27.3";
          src = pkgs.fetchurl {
            url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
            hash = "sha256-bndJA1zzYPBrJXXRYup535/ajvZxiJ5cN1+OUHd/Jrs=";
          };
        });
        buildGoModule = pkgs.buildGoModule.override { inherit go; };
      in
      {
        packages.default = buildGoModule {
          pname = "tailcat";
          version = self.shortRev or "dev";
          src = self;
          subPackages = [ "cmd/tailcat" ];
          vendorHash = flakeHashes.vendor.sri;
          meta = {
            description = "netcat over Tailscale's data plane, without its control plane";
            homepage = "https://github.com/tailscale/tailcat";
            license = pkgs.lib.licenses.bsd3;
            mainProgram = "tailcat";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [ go ];
        };
      });
}
# nix-direnv cache busting line: sha256-HtsiFgloxwTHSOaKFU6jx24vHBRDkI0feoRD0gEe+gk=
