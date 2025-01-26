# ╭──────────────────────────────────────────────────────────╮
# │ SwayNC                                                   │
# ╰──────────────────────────────────────────────────────────╯
{ meta, pkgs, ... }:
let
  inherit (meta) font;

  swaync-catppuccin-theme = pkgs.stdenv.mkDerivation {
    name = "swaync-catppuccin-theme";
    src = pkgs.fetchurl {
      url = "https://github.com/catppuccin/swaync/releases/latest/download/mocha.css";
      sha256 = "1xr1wkg4zb467b35xhsfqiwhimfnn88i3ml5rf173rkm7fyby9qy";
    };
    phases = [
      "unpackPhase"
      "patchPhase"
    ];
    unpackPhase = ''
      mkdir -p $out
      cp $src $out/mocha.css
    '';
    patchPhase = ''
      sed -i 's/font-family: [^;]*;/font-family: "${font.sans.name}";/g' $out/mocha.css
    '';
  };
in
{
  services.swaync.enable = true;
  xdg.configFile."swaync/style.css".source = "${swaync-catppuccin-theme}/mocha.css";
}
