-- ╭─────────────────────────────────────────────────────────╮
-- │ ICONS                                                   │
-- ╰─────────────────────────────────────────────────────────╯

---@class core.icons
local M = {}

M.kind = {
  Array = "",
  Boolean = "",
  Class = "",
  Color = "",
  Constant = "",
  Constructor = "",
  Enum = "",
  EnumMember = "",
  Event = "",
  Field = "",
  File = "",
  Folder = "",
  Function = "",
  Interface = "",
  Key = "",
  Keyword = "",
  Method = "",
  Module = "",
  Namespace = "",
  Null = "󰟢",
  Number = "",
  Object = "",
  Operator = "",
  Package = "",
  Property = "",
  Reference = "",
  Snippet = "",
  String = "",
  Struct = "",
  Text = "",
  TypeParameter = "",
  Unit = "",
  Value = "",
  Variable = "",
}

M.ui = {
  Ellipsis = "",
  LineLeft = "▏",
  Tab = "󰌒",
}

M.dap = {
  Breakpoint = "",
  BreakpointCondition = "",
  BreakpointRejected = "",
  LogPoint = "",
  Stopped = "",
}

return M
