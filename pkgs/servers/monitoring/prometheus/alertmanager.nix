{ stdenv, go, buildGoPackage, fetchFromGitHub, installShellFiles }:

buildGoPackage rec {
  pname = "alertmanager";
  version = "0.20.0";
  rev = "v${version}";

  goPackagePath = "github.com/prometheus/alertmanager";

  src = fetchFromGitHub {
    inherit rev;
    owner = "prometheus";
    repo = "alertmanager";
    sha256 = "1bq6vbpy25k7apvs2ga3fbp1cbnv9j0y1g1khvz2qgz6a2zvhgg3";
  };

  buildFlagsArray = let t = "${goPackagePath}/vendor/github.com/prometheus/common/version"; in ''
    -ldflags=
       -X ${t}.Version=${version}
       -X ${t}.Revision=${src.rev}
       -X ${t}.Branch=unknown
       -X ${t}.BuildUser=nix@nixpkgs
       -X ${t}.BuildDate=unknown
       -X ${t}.GoVersion=${stdenv.lib.getVersion go}
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $bin/bin/amtool --completion-script-bash > amtool.bash
    installShellCompletion amtool.bash
  '';

  meta = with stdenv.lib; {
    description = "Alert dispatcher for the Prometheus monitoring system";
    homepage = "https://github.com/prometheus/alertmanager";
    license = licenses.asl20;
    maintainers = with maintainers; [ benley fpletz globin ];
    platforms = platforms.unix;
  };
}
