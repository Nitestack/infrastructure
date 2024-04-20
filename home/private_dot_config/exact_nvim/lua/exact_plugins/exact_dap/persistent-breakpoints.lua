local event = { "BufReadPost" }

---@type LazyPluginSpec
return {
  "Weissle/persistent-breakpoints.nvim",
  event = event,
  cmd = {
    "PBToggleBreakpoint",
    "PBSetConditionalBreakpoint",
    "PBClearAllBreakpoints",
    "PBReload",
    "PBStore",
    "PBLoad",
  },
  keys = core.lazy_map({
    n = {
      [{ "<leader>db", "<F9>" }] = {
        function()
          require("persistent-breakpoints.api").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      ["<leader>dB"] = {
        function()
          require("persistent-breakpoints.api").clear_all_breakpoints()
        end,
        desc = "Clear Breakpoints",
      },
      [{ "<leader>dC", "<F21>" }] = { -- <F21> translates to Shift+F9
        function()
          require("persistent-breakpoints.api").set_conditional_breakpoint()
        end,
        desc = "Set Breakpoint Condition",
      },
    },
  }),
  opts = {
    load_breakpoints_event = event,
  },
}
