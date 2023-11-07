{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  sassc,
  gtk3,
  inkscape,
  optipng,
  gtk-engine-murrine,
  gdk-pixbuf,
  librsvg,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "pop-gtk-theme";
  version = "5.4.4";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "gtk-theme";
    rev = "4ae6ff308432b79a801bb29522aa19d1e7ee51ab";
    sha256 = "sha256-7lfSe12kN6zvf7ox+slAkf3SCYnIMapdtiCQ4P9CXHk=";
  };

  nativeBuildInputs = [
    meson
    ninja
    sassc
    gtk3
    inkscape
    optipng
    python3
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  postPatch = ''
    patchShebangs .

    for file in $(find -name render-\*.sh); do
      substituteInPlace "$file" \
        --replace 'INKSCAPE="/usr/bin/inkscape"' \
                  'INKSCAPE="${inkscape}/bin/inkscape"' \
        --replace 'OPTIPNG="/usr/bin/optipng"' \
                  'OPTIPNG="${optipng}/bin/optipng"'
    done
  '';

  meta = with lib; {
    description = "System76 Pop GTK+ Theme";
    homepage = "https://github.com/pop-os/gtk-theme";
    license = with licenses; [gpl3 lgpl21 cc-by-sa-40];
    platforms = platforms.linux;
    maintainers = with maintainers; [];
  };
}
