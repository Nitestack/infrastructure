# ╭──────────────────────────────────────────────────────────╮
# │ sddm-astronaut-theme                                     │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, lib, ... }:
let
  themeConfig = {
    PartialBlur = false;
    Font = "\"Rubik\"";
    DateFormat = "\"dddd, MMMM d\"";
  };
in
pkgs.stdenv.mkDerivation {
  name = "sddm-astronaut-theme";
  src = pkgs.fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "2bb6702a5ddc9417aadbebd6d66aae14973e47ea";
    sha256 = "0djxiy8pzigw3rf81z59n36r6lw8cqf9hrxl3vjsg5267k8kjqhp";
  };

  dontWrapQtApps = true;
  propagatedBuildInputs = with pkgs.kdePackages; [
    qtsvg
  ];

  installPhase =
    let
      iniFormat = pkgs.formats.ini { };
      configFile = iniFormat.generate "" { General = themeConfig; };

      basePath = "$out/share/sddm/themes/sddm-astronaut-theme";
    in
    ''
      mkdir -p ${basePath}
      cp -r $src/* ${basePath}
    ''
    + lib.optionalString (themeConfig != null) ''
      ln -sf ${configFile} ${basePath}/theme.conf.user
    '';
}
