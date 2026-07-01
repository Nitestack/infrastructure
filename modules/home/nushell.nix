# ╭──────────────────────────────────────────────────────────╮
# │ Nushell                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  lib,
  pkgs,
  ...
}:
{
  programs = {
    nushell = {
      enable = true;
      settings = {
        # History
        history = {
          file_format = "sqlite";
          max_size = 5000000;
        };

        # Misc
        show_banner = false;
        rm.always_trash = true;

        # Cmdline Editor
        edit_mode = "vi";
        buffer_editor = "nvim";
        cursor_shape.vi_normal = "block";
        cursor_shape.vi_insert = "line";

        # Table
        table.mode = "compact";

        # Completion
        completions.algorithm = "fuzzy";

        # Colors
        highlight_resolved_externals = lib.hm.nushell.mkNushellInline "not (sys host | get kernel_version | str contains \"microsoft-standard-WSL2\")";
      };
      environmentVariables = {
        DISABLE_NON_ESSENTIAL_MODEL_CALLS = "1";
        PROMPT_INDICATOR_VI_NORMAL = "";
        PROMPT_INDICATOR_VI_INSERT = "";
        LS_COLORS = "(${pkgs.vivid}/bin/vivid generate catppuccin-mocha)";
        ENV_CONVERSIONS =
          let
            colon_conversion = {
              from_string = lib.hm.nushell.mkNushellInline "{ |s| $s | split row (char esep) | path expand --no-symlink }";
              to_string = lib.hm.nushell.mkNushellInline "{ |v| $v | path expand --no-symlink | str join (char esep) }";
            };
          in
          {
            XDG_CONFIG_DIRS = colon_conversion;
            XDG_DATA_DIRS = colon_conversion;
          };
      };
      extraConfig =
        let
          catppuccin-repo = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "nushell";
            rev = "05987d258cb765a881ee1f2f2b65276c8b379658";
            sha256 = "13a2am30w1v8lz7drc04z3762jrywdqflfbn446iab6slfpw23dm";
          };
        in
        ''
          source ${catppuccin-repo}/themes/catppuccin_mocha.nu
        '';
    };
    # Start Nushell for normal interactive Zsh sessions,
    # while keeping Zsh as the actual login shell.
    zsh.initContent = lib.mkOrder 500 ''
      if [[ -o interactive ]] \
        && [[ -t 0 ]] \
        && [[ -t 1 ]] \
        && [[ -z "''${NO_NU:-}" ]] \
        && [[ "''${TERM:-}" != "dumb" ]]; then
        exec ${lib.getExe pkgs.nushell}
      fi
    '';
  };
}
