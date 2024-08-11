{
  description = "Shell configuration for CCR";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        coq = pkgs.coq_8_15;
        coqPackages = pkgs.mkCoqPackages coq;
        callPackage = pkgs.lib.callPackageWith (pkgs // params // set);
        params = {
          lib = import (nixpkgs + "/pkgs/build-support/coq/extra-lib.nix") { lib = pkgs.lib; };
          inherit (coqPackages) mkCoqDerivation;
          inherit (coq) ocaml ocamlPackages;
        };
        set = rec {
          inherit coq;
          menhir = coq.ocamlPackages.menhir;
          menhirLib = coq.ocamlPackages.menhirLib;
          paco = callPackage coqPackages.paco.override { version = "4.1.2"; };
          coq-ext-lib = callPackage coqPackages.coq-ext-lib.override { version = "0.12.0"; };
          ITree = callPackage coqPackages.ITree.override { version = "4.0.0"; };
          ordinal = callPackage ./ordinal { version = "0.5.2"; };
          stdpp = callPackage coqPackages.stdpp.override { version = "1.7.0"; };
          iris = callPackage coqPackages.iris.override { version = "3.6.0"; };
          flocq = callPackage coqPackages.flocq.override { version = "4.2.0"; };
          coq-menhirlib = callPackage ./coq-menhirlib { version = menhir.version; };
          compcert = callPackage (coqPackages.compcert.overrideAttrs (oldAttrs: {
            buildInputs = oldAttrs.buildInputs ++ [ coq-menhirlib ];
            configurePhase = ''
              ./configure -clightgen \
              -prefix $out \
              -coqdevdir $lib/lib/coq/${coq.coq-version}/user-contrib/compcert/ \
              -toolprefix ${pkgs.stdenv.cc}/bin/ \
              -use-external-Flocq \
              -use-external-MenhirLib \
              x86_64-linux
            '';
          })).override { version = "3.11"; };
        };
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [ coq.ocamlPackages.ocamlbuild ];
          buildInputs = pkgs.lib.attrValues set;
        };
      }
    );
}
