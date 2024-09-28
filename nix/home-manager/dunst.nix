# ╭──────────────────────────────────────────────────────────╮
# │ Dunst                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ meta, ... }:
let
  inherit (meta) font iconTheme;
in
{
  services.dunst = {
    inherit iconTheme;
    enable = true;
    settings = {
      global = {
        font = font.sans.name;

        frame_color = "#89b4fa";
        separator_color = "frame";
      };
      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
      };
      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
      };
      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#fab387";
      };
    };
  };
}
