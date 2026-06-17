# ╭──────────────────────────────────────────────────────────╮
# │ LogiOps                                                  │
# ╰──────────────────────────────────────────────────────────╯

# ── Haptic Effect ─────────────────────────────────────────────────────
# 0  = prominent double-click style effect
# 4  = subtle single click
# 8  = strength-preview style vibration sequence
# 1–14 = additional community-discovered patterns
# ── Haptic Strength ───────────────────────────────────────────────────
# subtle = 15
# low = 45
# medium = 60
# high = 100
{
  services.logiops = {
    enable = true;
    config = {
      devices = [
        {
          name = "MX Master 4";
          dpi = 1200;
          smartshift = {
            on = true;
            threshold = 15;
            default_threshold = 15;
          };
          hiresscroll = {
            hires = true;
          };
          haptic_feedback = {
            enabled = true;
            strength = 60;
            battery_saving = true;
          };
          buttons = [
            {
              cid = 196; # 0xc4 — top button behind wheel
              action = {
                type = "Gestures";
                gestures = [
                  {
                    direction = "None";
                    mode = "OnRelease";
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_PLAYPAUSE" ];
                    };
                  }
                  {
                    direction = "Left";
                    mode = "OnRelease";
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_PREVIOUSSONG" ];
                    };
                  }
                  {
                    direction = "Right";
                    mode = "OnRelease";
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_NEXTSONG" ];
                    };
                  }
                  {
                    direction = "Up";
                    mode = "OnInterval";
                    interval = 50;
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_VOLUMEUP" ];
                    };
                  }
                  {
                    direction = "Down";
                    mode = "OnInterval";
                    interval = 50;
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_VOLUMEDOWN" ];
                    };
                  }
                ];
              };
            }
            {
              cid = 195; # 0xc3 — extra side button
              action = {
                type = "Gestures";
                gestures = [
                  {
                    direction = "None";
                    mode = "OnRelease";
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [
                        "KEY_LEFTMETA"
                        "KEY_TAB"
                      ];
                    };
                  }
                  {
                    direction = "Left";
                    mode = "OnRelease";
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [
                        "KEY_LEFTMETA"
                        "KEY_LEFTCTRL"
                        "KEY_H"
                      ];
                    };
                  }
                  {
                    direction = "Right";
                    mode = "OnRelease";
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [
                        "KEY_LEFTMETA"
                        "KEY_LEFTCTRL"
                        "KEY_L"
                      ];
                    };
                  }
                  {
                    direction = "Up";
                    mode = "OnRelease";
                    haptic_effect = 4;
                    action = {
                      type = "Keypress";
                      keys = [
                        "KEY_LEFTALT"
                        "KEY_SPACE"
                      ];
                    };
                  }
                ];
              };
            }
            {
              cid = 416; # 0x1a0 — thumb pad / gesture area
              action = {
                type = "Gestures";
                gestures = [
                  {
                    direction = "Left";
                    mode = "OnRelease";
                    haptic_effect = 0;
                    action = {
                      type = "ChangeHost";
                      host = 1;
                    };
                  }
                  {
                    direction = "Right";
                    mode = "OnRelease";
                    haptic_effect = 0;
                    action = {
                      type = "ChangeHost";
                      host = 2;
                    };
                  }
                ];
              };
            }
          ];
        }
      ];
    };
  };

}
