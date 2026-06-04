# ╭──────────────────────────────────────────────────────────╮
# │ Animations                                               │
# ╰──────────────────────────────────────────────────────────╯
{
  wayland.windowManager.hyprland.settings = {
    config.animations.enabled = true;

    curve = [
      {
        _args = [
          "emphasizedDecel"
          {
            type = "bezier";
            points = [
              [
                0.05
                0.7
              ]
              [
                0.1
                1.0
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "emphasizedAccel"
          {
            type = "bezier";
            points = [
              [
                0.3
                0.0
              ]
              [
                0.8
                0.15
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "standardDecel"
          {
            type = "bezier";
            points = [
              [
                0
                0
              ]
              [
                0
                1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "menu_decel"
          {
            type = "bezier";
            points = [
              [
                0.1
                1.0
              ]
              [
                0.0
                1.0
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "menu_accel"
          {
            type = "bezier";
            points = [
              [
                0.52
                0.03
              ]
              [
                0.72
                0.08
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "stall"
          {
            type = "bezier";
            points = [
              [
                1
                (-0.1)
              ]
              [
                0.7
                0.85
              ]
            ];
          }
        ];
      }
    ];

    animation =
      let
        anim = leaf: speed: bezier: style: {
          inherit leaf speed bezier;
          enabled = true;
          inherit style;
        };
        animSimple = leaf: speed: bezier: {
          inherit leaf speed bezier;
          enabled = true;
        };
      in
      [
        (anim "windowsIn" 3 "emphasizedDecel" "popin 80%")
        (animSimple "fadeIn" 3 "emphasizedDecel")
        (anim "windowsOut" 2 "emphasizedDecel" "popin 90%")
        (animSimple "fadeOut" 2 "emphasizedDecel")
        (anim "windowsMove" 3 "emphasizedDecel" "slide")
        (animSimple "border" 10 "emphasizedDecel")

        (anim "layersIn" 2.7 "emphasizedDecel" "popin 93%")
        (anim "layersOut" 2.4 "menu_accel" "popin 94%")

        (animSimple "fadeLayersIn" 0.5 "menu_decel")
        (animSimple "fadeLayersOut" 2.7 "stall")

        (anim "workspaces" 7 "menu_decel" "slide")
        (anim "specialWorkspaceIn" 2.8 "emphasizedDecel" "slidevert")
        (anim "specialWorkspaceOut" 1.2 "emphasizedAccel" "slidevert")

        (animSimple "zoomFactor" 3 "standardDecel")
      ];
  };
}
