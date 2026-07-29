# Windows Terminal keybindings for Herdr

Herdr uses `ctrl+alt+h`, `ctrl+alt+j`, `ctrl+alt+k`, `ctrl+alt+l`,
`ctrl+alt+[`, and `ctrl+alt+]` for navigation. When running Herdr in a WSL
session launched from Windows Terminal, Windows Terminal must send the
corresponding CSI-u sequences; otherwise the keys do not reach Herdr
distinctly.

In Windows Terminal, open **Settings** → **Open JSON file** and merge these
entries into the existing `actions` array:

```json
[
  { "command": { "action": "sendInput", "input": "\u001b[104;7u" }, "keys": "ctrl+alt+h" },
  { "command": { "action": "sendInput", "input": "\u001b[106;7u" }, "keys": "ctrl+alt+j" },
  { "command": { "action": "sendInput", "input": "\u001b[107;7u" }, "keys": "ctrl+alt+k" },
  { "command": { "action": "sendInput", "input": "\u001b[108;7u" }, "keys": "ctrl+alt+l" },
  { "command": { "action": "sendInput", "input": "\u001b[91;7u" }, "keys": "ctrl+alt+[" },
  { "command": { "action": "sendInput", "input": "\u001b[93;7u" }, "keys": "ctrl+alt+]" }
]
```

Current Windows Terminal releases may normalize these entries into separate
`actions` and `keybindings` arrays automatically; that is equivalent.
