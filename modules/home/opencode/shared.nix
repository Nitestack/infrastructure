{
  plugin = [
    [
      "opencode-claude-code-bridge@0.2.1"
      {
        mcp = false;
      }
    ]
  ];

  # Enter submits from insert mode. `Ctrl+Enter` still inserts a newline
  # (input_newline's default binding), so this doesn't need a keybind
  # override. `input_force_submit`, mentioned in the opencode-vim README, is
  # not implemented in the pinned revision — only vim_enter_submit is wired
  # up (packages/tui/src/component/prompt/index.tsx, submitFromTextarea).
  tui = {
    vim_enter_submit = true;
  };
}
