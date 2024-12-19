{
  stdenvNoCC,
  lib,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "iosevka-nerd";
  version = "3.2.1";

  src = fetchurl {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/IosevkaTerm.tar.xz";
    sha256 = "sha256-tdXnsmx28c/peml3Fv3WgrGPr59ziDkVwrDC2fzEjPU=";
  };

  unpackPhase = ''
    mkdir -p $out/share/fonts
    tar -xf $src -C $out/share/fonts
  '';

  meta = with lib; {
    description = ''
      Nerd Fonts is a project that attempts to patch as many developer targeted
      and/or used fonts as possible. The patch is to specifically add a high
      number of additional glyphs from popular 'iconic fonts' such as Font
      Awesome, Devicons, Octicons, and others.
    '';
    homepage = "https://github.com/ryanoasis/nerd-fonts";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
