{ lib, 
  fetchFromGitHub, 
  rustPlatform,
  pkg-config,
  gtk3
}:

rustPlatform.buildRustPackage rec {
  pname = "satty";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "ElysaSrc";
    repo = pname;
    rev = "2ee811a616787f3e874e22c11883cd56246486c5";
    hash = "sha256-4b4ivN8Rkclslla7uVFBLDDGosHZac7avIyltBI4zcs=";
  };

  cargoHash = "";

  nativeBuildInputs = [
    pkg-config
    gtk3
  ];

  meta = with lib; {
    description = "A Screenshot Annotation Tool inspired by Swappy and Flameshot";
    homepage = "https://github.com/gabm/satty";
    license = licenses.mpl20;
    maintainers = [];
  };
}
