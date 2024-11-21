# ╭──────────────────────────────────────────────────────────╮
# │ OVERLAYS                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  # Brings custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # Change versions, add patches, set compilation flags, ...
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    tmuxPlugins = prev.tmuxPlugins // {
      tokyo-night-tmux = prev.tmuxPlugins.tokyo-night-tmux.overrideAttrs (oldAttrs: {
        version = "1.5.5";
        src = prev.fetchFromGitHub {
          owner = "janoamaral";
          repo = "tokyo-night-tmux";
          rev = "b45b742eb3fdc01983c21b1763594b549124d065";
          hash = "sha256-k4CbfWdyk7m/T97ytxLOEMUKrkU5iJSIu3lvyT1B1jU=";
        };
      });
    };
    magnetic-catppuccin-gtk = prev.magnetic-catppuccin-gtk.overrideAttrs (oldAttrs: {
      version = "0-unstable-2024-11-06";
      src = prev.fetchFromGitHub {
        owner = "Fausto-Korpsvart";
        repo = "Catppuccin-GTK-Theme";
        rev = "be79b8289200aa1a17620f84dde3fe4c3b9c5998";
        hash = "sha256-QItHmYZpe7BiPC+2CtFwiRXyMTG7+ex0sJTs63xmkAo=";
      };
    });
  };
}
