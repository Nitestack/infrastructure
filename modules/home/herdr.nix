# ╭──────────────────────────────────────────────────────────╮
# │ Herdr                                                    │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  lib,
  pkgs,
  ...
}:
let
  hc = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr-core;

  # Start the herdr-core server from a login zsh so Home Manager session
  # variables (e.g. NH_FLAKE) are loaded once. Panes inherit that environment.
  herdrCoreStart = pkgs.writeShellScript "herdr-core-start" ''
    exec ${lib.getExe pkgs.zsh} -l -c 'exec ${lib.getExe hc} server start'
  '';
in
{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;
      theme.custom.sidebar_bg = "#181825";
      terminal.default_shell = lib.getExe pkgs.nushell;
      keys = {
        prefix = "ctrl+a";
        previous_tab = "ctrl+alt+h";
        next_tab = "ctrl+alt+l";
        previous_workspace = "ctrl+alt+k";
        next_workspace = "ctrl+alt+j";
        previous_agent = "ctrl+alt+[";
        next_agent = "ctrl+alt+]";
        copy_mode = "prefix+v";
        split_vertical = "prefix+|";
        split_horizontal = "prefix+minus";
      };
      ui = {
        pane_borders = false;
        agent_panel_sort = "priority";
        hide_tab_bar_when_single_tab = true;
        prompt_new_tab_name = false;
        toast.delivery = "system";
      };
    };
  };

  home.packages = [ hc ];

  systemd.user.services.herdr-core = {
    Service = {
      Type = "oneshot";
      ExecStart = "${herdrCoreStart}";
    };

    Install.WantedBy = [ "default.target" ];
  };

  xdg.configFile."herdr-core/config.toml".source =
    (pkgs.formats.toml { }).generate "herdr-core-config.toml"
      {
        shell = [
          (lib.getExe pkgs.nushell)
        ];
      };
}
