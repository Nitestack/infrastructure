# ╭──────────────────────────────────────────────────────────╮
# │ Audio                                                    │
# ╰──────────────────────────────────────────────────────────╯
{
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire."10-quality-settings" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [
          44100
          48000
          96000
        ];
        "module.switch-on-connect" = true;
      };
      "stream.properties" = {
        "channelmix.mix-lfe" = true;
        "resample.quality" = 10;
      };
    };
  };
  security.rtkit.enable = true;
}
