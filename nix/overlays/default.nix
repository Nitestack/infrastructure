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
}
