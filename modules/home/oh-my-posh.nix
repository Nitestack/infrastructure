# ╭──────────────────────────────────────────────────────────╮
# │ Oh My Posh                                               │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.oh-my-posh = {
    enable = true;
    settings = {
      final_space = true;
      upgrade_notice = false;
      version = 2;
      console_title_template = "{{ if .WSL }}WSL: {{ end }}{{ .Shell }} in {{ .Folder }}";
      blocks = [
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              type = "os";
              style = "plain";
              foreground_templates = [
                "{{ if eq .OS \"nixos\" }}#5277C3{{ end }}"
                "{{ if eq .OS \"raspbian\" }}#C51D4A{{ end }}"
              ];
              background = "transparent";
              template = "{{ .Icon }} ";
            }
            {
              type = "path";
              style = "plain";
              background = "transparent";
              foreground = "blue";
              template = "{{ .Path }}";
              properties = {
                folder_separator_icon = "/";
                style = "full";
              };
            }
            {
              type = "session";
              style = "plain";
              foreground = "yellow";
              background = "transparent";
              template = "{{ if .SSHSession }} (SSH){{ end }}";
            }
            {
              type = "nix-shell";
              style = "plain";
              foreground = "blue";
              background = "transparent";
              template = "{{ if ne .Type \"unknown\" }} (Nix Shell){{ end }}";
            }
            {
              type = "git";
              style = "plain";
              foreground = "yellow";
              foreground_templates = [
                "{{ if or (.Working.Changed) (.Staging.Changed) }}#fab387{{ end }}"
                "{{ if and (gt .Ahead 0) (gt .Behind 0) }}red{{ end }}"
                "{{ if gt .Ahead 0 }}#cba6f7{{ end }}"
                "{{ if gt .Behind 0 }}#cba6f7{{ end }}"
              ];
              background = "transparent";
              properties = {
                fetch_status = true;
                fetch_upstream_icon = true;
              };
            }
          ];
        }
        {
          type = "rprompt";
          overflow = "hidden";
          segments = [
            {
              type = "executiontime";
              style = "plain";
              foreground = "green";
              foreground_templates = [ "{{ if gt .Code 0 }}red{{ end }}" ];
              background = "transparent";
              properties = {
                threshold = 5000;
              };
            }
          ];
        }
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              type = "text";
              style = "plain";
              foreground_templates = [
                "{{ if or .Root (gt .Code 0) }}red{{ end }}"
                "{{ if eq .Code 0 }}magenta{{ end }}"
              ];
              background = "transparent";
              template = "{{ if .Root }}{{ else }}{{ end }}";
            }
          ];
        }
      ];
      transient_prompt = {
        foreground_templates = [
          "{{ if gt .Code 0 }}red{{ end }}"
          "{{ if eq .Code 0 }}magenta{{ end }}"
        ];
        background = "transparent";
        template = "❯ ";
      };
      secondary_prompt = {
        foreground = "magenta";
        background = "transparent";
        template = "❯❯ ";
      };
    };
  };
}
