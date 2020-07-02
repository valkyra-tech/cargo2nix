{
  system ? builtins.currentSystem,
  nixpkgsMozilla ? builtins.fetchGit {
    url = https://github.com/mozilla/nixpkgs-mozilla;
    rev = "50bae918794d3c283aeb335b209efd71e75e3954";
  },
  cargo2nix ? builtins.fetchGit {
    url = https://github.com/tenx-tech/cargo2nix;
    # TODO: pin to tag once v0.8.3 is released (see https://github.com/tenx-tech/cargo2nix/issues/96)
    ref = "master";
  },
}:
let
  rustOverlay = import "${nixpkgsMozilla}/rust-overlay.nix";
  cargo2nixOverlay = import "${cargo2nix}/overlay";

  pkgs = import <nixpkgs> {
    inherit system;
    overlays = [ cargo2nixOverlay rustOverlay ];
  };

  rustPkgs = pkgs.rustBuilder.makePackageSet' {
    rustChannel = "stable";
    packageFun = import ./Cargo.nix;
    localPatterns =
      [
        ''^(src|tests)(/.*)?''
        ''[^/]*\.(rs|toml)$''
        # include other directory from the project repository
        ''^templates(/.*)?''
      ];
  };
in
  rustPkgs.workspace.project-with-resources {}
