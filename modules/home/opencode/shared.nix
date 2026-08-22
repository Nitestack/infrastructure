{
  plugin = [
    [
      "opencode-claude-code-bridge@0.2.1"
      {
        mcp = false;
      }
    ]
  ];

  tui = {
    theme = "catppuccin";
    plugin = [
      [
        "@leohenon/opencode-vim-plugin@0.1.6"
        {
          enabled = true;
          vim_enter_submit = true;
          vim_insert_after_submit = true;
          vim_system_clipboard_register = true;
        }
      ]
    ];
  };
}
