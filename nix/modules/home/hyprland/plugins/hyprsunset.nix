# ╭──────────────────────────────────────────────────────────╮
# │ Hyprsunset                                               │
# ╰──────────────────────────────────────────────────────────╯
_: {
  services.hyprsunset = {
    enable = true;
    settings.profile = [
      {
        time = "06:00";
        identity = true;
      }
      {
        time = "19:00";
        temperature = 3500;
      }
    ];
  };
}
