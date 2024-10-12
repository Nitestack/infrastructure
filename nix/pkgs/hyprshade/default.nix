# ╭──────────────────────────────────────────────────────────╮
# │ Hyprshade                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  lib,
  pkgs,
  ...
}:
pkgs.python3Packages.buildPythonPackage rec {
  name = "hyprshade";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "loqusion";
    repo = name;
    rev = "152cd2ea06d9412d62bc628d62ee5af7771190b1";
    sha256 = "0wf1iqikfg7539k7hf5bbrhzwxfhgwwmkng0sb2bw712cbnhy6jm";
  };

  nativeBuildInputs = [
    pkgs.python3Packages.hatchling
    pkgs.makeWrapper
  ];

  propagatedBuildInputs = [
    pkgs.python3Packages.more-itertools
    pkgs.python3Packages.click
    (pkgs.python3Packages.buildPythonPackage rec {
      pname = "chevron";
      version = "0.14.0"; # >= 0.14.0 is required for hyprshade
      src = pkgs.python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "87613aafdf6d77b6a90ff073165a61ae5086e21ad49057aa0e53681601800ebf";
      };
    })
  ];

  postFixup = ''
    wrapProgram $out/bin/hyprshade \
      --set HYPRSHADE_SHADERS_DIR $out/share/hyprshade/shaders \
      --prefix PATH : ${lib.makeBinPath [ pkgs.hyprland ]}
  '';
}
