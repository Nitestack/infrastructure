# ╭──────────────────────────────────────────────────────────╮
# │ Overlays                                                 │
# ╰──────────────────────────────────────────────────────────╯
final: prev: {
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
}
