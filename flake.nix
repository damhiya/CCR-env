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
        set = {
          inherit coq;
          paco = callPackage coqPackages.paco.override { version = "4.1.2"; };
          coq-ext-lib = callPackage coqPackages.coq-ext-lib.override { version = "0.12.0"; };
          ITree = callPackage coqPackages.ITree.override { version = "4.0.0"; };
          ordinal = callPackage ./ordinal { version = "0.5.2"; };
          stdpp = callPackage coqPackages.stdpp.override { version = "1.7.0"; };
          iris = callPackage coqPackages.iris.override { version = "3.6.0"; };
          flocq = callPackage coqPackages.flocq.override { version = "4.2.0"; };
          compcert = callPackage coqPackages.compcert.override { version = "3.11"; };
        };
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [ params.ocamlPackages.ocamlbuild ];
          buildInputs = pkgs.lib.attrValues set;
        };
      }
    );
}
