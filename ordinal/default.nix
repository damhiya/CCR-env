{ lib, mkCoqDerivation, coq, version ? null }:
mkCoqDerivation {
  pname = "Ordinal";
  inherit version;
  owner = "snu-sf";
  release."0.5.2".sha256 = "sha256-jf16EyLAnKm+42K+gTTHVFJqeOVQfIY2ozbxIs5x5DE=";
  releaseRev = v: "v${v}";

  installPhase = ''
    make -f Makefile.coq COQMF_COQLIB=$out/lib/coq/${coq.coq-version}/ install
  '';
}
