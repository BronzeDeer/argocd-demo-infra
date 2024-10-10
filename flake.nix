{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils
  }:
  # Nix supports many different os/arch combinations, but in practice we mostly care about support x86_64 and arm for linux and darwin (macOS)
  # The list maintained by as "defaultSystems" is exactly this, i.e. ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]
  flake-utils.lib.eachDefaultSystem (
    system: let
      pkgs = import nixpkgs{inherit system;};
    in rec {
      # TODO: Create PR to avoid rec pattern ( Not possible till buildGoModule is reworked further :/)
      chainsaw_latest = (pkgs.kyverno-chainsaw.override {
                # Needs go 1.23 from here on, but unstable is still on 1.22
                buildGoModule = pkgs.buildGo123Module;
             }).overrideAttrs (
              finalAttrs: previousAttrs: rec{
                version = "0.2.9-20-g9ecfefff";
                src = pkgs.fetchFromGitHub {
                  inherit (previousAttrs.src) owner repo;
                  # Force rebuild/recheck hash if rev changes
                  name = "${version}";
                  rev = "9ecfefffe32220ad5e0bec57feb93faaa1435c38";
                  hash = "sha256-YfIUEqKtPvN0vsV8dhonCInA+pnJ8tdLZZ8Ma9ZMM24=";
                };
                vendorHash = "sha256-nrgAYrpBirB3C1/ia+oddkQoWCYd+O/NOUfr+svutAg=";

                # Note that Build flags (and therefore chainsaw version) will still be wrong
                  ldflags = [
                  "-s"
                  "-w"
                  "-X github.com/kyverno/chainsaw/pkg/version.BuildVersion=v${version}"
                  "-X github.com/kyverno/chainsaw/pkg/version.BuildHash=${version}"
                  "-X github.com/kyverno/chainsaw/pkg/version.BuildTime=1970-01-01_00:00:00"
                ];

                # Do not build hack/controller-gen
                subPackages = ["."];
            });
      chainsaw_0_2_9 = (pkgs.kyverno-chainsaw.override {
                # Needs go 1.23 from here on, but unstable is still on 1.22
                buildGoModule = pkgs.buildGo123Module;
             }).overrideAttrs (
              finalAttrs: previousAttrs: rec{
                version = "0.2.9";
                src = pkgs.fetchFromGitHub {
                  inherit (previousAttrs.src) owner repo;
                  # Force rebuild/recheck hash if rev changes
                  name = "v${version}";
                  rev = "v${version}";
                  hash = "sha256-xo2iQh8jQCc5kmi0vmO5XEliBl5glsRJReSn2XVCOVU=";
                };
                vendorHash = "sha256-OLJGSQwYYo3l84hYjnGYOK3cCe/H5JJbgYuTYaTvplY=";

                # Note that Build flags (and therefore chainsaw version) will still be wrong
                ldflags = [
                  "-s"
                  "-w"
                  "-X github.com/kyverno/chainsaw/pkg/version.BuildVersion=v${version}"
                  "-X github.com/kyverno/chainsaw/pkg/version.BuildHash=${version}"
                  "-X github.com/kyverno/chainsaw/pkg/version.BuildTime=1970-01-01_00:00:00"
                ];

                # The current 0.2.8 package set the wrong name for the completion function
                postInstall = pkgs.lib.optionalString (pkgs.stdenv.buildPlatform.canExecute pkgs.stdenv.hostPlatform) ''
                  for shell in bash fish zsh; do
                    installShellCompletion --cmd chainsaw \
                      --$shell <($out/bin/chainsaw completion $shell )
                  done
                '';

                # Do not build hack/controller-gen
                subPackages = [
                  "."
                ];
            });
      devShells.default = pkgs.mkShell {
          packages = [
            # This gives us both the new version and fixes the bug with the completions script
            chainsaw_0_2_9
          ];
      };
      defaultPackage = devShells.default; # Allow nix build to also pick up the shell by default
    }
  );
}
