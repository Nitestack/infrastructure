# ╭──────────────────────────────────────────────────────────╮
# │ Nushell                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  programs = {
    nushell = {
      enable = true;
      environmentVariables = {
        PROMPT_INDICATOR_VI_NORMAL = "";
        PROMPT_INDICATOR_VI_INSERT = "";
      };
      settings = {
        # History
        history = {
          file_format = "sqlite";
          max_size = 5000000;
          isolation = false;
        };
        # Misc
        show_banner = false;
        rm.always_trash = true;
        # Cmdline Editor
        edit_mode = "vi";
        buffer_editor = "nvim";
        cursor_shape = {
          vi_normal = "block";
          vi_insert = "line";
        };
        # Table
        table.mode = "compact";
        # Completion
        completions.algorithm = "fuzzy";
      };
      extraConfig =
        let
          fastfetch = "${pkgs.fastfetch}/bin/fastfetch";
          vivid = "${pkgs.vivid}/bin/vivid";
        in
        ''
          let host = {
            is-wsl: (sys host | get kernel_version | str contains "microsoft-standard-WSL2")
          }
          $env.LS_COLORS = (${vivid} generate catppuccin-mocha)
          $env.config.highlight_resolved_externals = not $host.is-wsl

          ${fastfetch}
        '';
    };
  };
}
