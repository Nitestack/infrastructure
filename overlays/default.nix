# ╭──────────────────────────────────────────────────────────╮
# │ Overlays                                                 │
# ╰──────────────────────────────────────────────────────────╯
_: final: prev: {
  logiops = prev.logiops.overrideAttrs (oldAttrs: {
    version = "0.3.5-davifochi-haptic-feedback";
    src = prev.fetchFromGitHub {
      owner = "davifochi";
      repo = "logiops";
      rev = "7f6b0667516b723b237bf81a3efa72b49c30ee08";
      hash = "sha256-Placect/XRnRN0MDqL9fkaIiOsfO1K6hM8XrM1wtmUg=";
      fetchSubmodules = true;
    };
  });
}
