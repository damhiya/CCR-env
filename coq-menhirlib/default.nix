{ mkCoqDerivation, coq, version ? null }:
mkCoqDerivation {
  pname = "coq-menhirlib";
  inherit version;
  domain = "gitlab.inria.fr";
  owner = "fpottier";
  repo = "menhir";
  release."20231231".sha256 = "sha256-veB0ORHp6jdRwCyDDAfc7a7ov8sOeHUmiELdOFf/QYk=";

  preBuild = ''
    cd coq-menhirlib/src
  '';
}
