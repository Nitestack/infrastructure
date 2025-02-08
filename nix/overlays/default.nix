# ╭──────────────────────────────────────────────────────────╮
# │ Overlays                                                 │
# ╰──────────────────────────────────────────────────────────╯
{ ... }:
final: prev: {
  tmuxPlugins = prev.tmuxPlugins // {
    tokyo-night-tmux = prev.tmuxPlugins.tokyo-night-tmux.overrideAttrs (oldAttrs: {
      version = "1.6.1";
      src = prev.fetchFromGitHub {
        owner = "janoamaral";
        repo = "tokyo-night-tmux";
        rev = "d610ced20d5f602a7995854931440e4a1e0ab780";
        hash = "sha256-17vEgkL7C51p/l5gpT9dkOy0bY9n8l0/LV51mR1k+V8=";
      };
    });
  };
  sddm-astronaut = prev.sddm-astronaut.overrideAttrs (oldAttrs: {
    propagatedUserEnvPkgs = oldAttrs.propagatedBuildInputs;
    propagatedBuildInputs = [ ];

    installPhase =
      oldAttrs.installPhase
      + ''

        themeDir="$out/share/sddm/themes/sddm-astronaut-theme"

        mkdir -p $out/share/fonts
        ln -s $out/share/sddm/themes/sddm-astronaut-theme/Fonts/* $out/share/fonts/
      '';
  });
}
