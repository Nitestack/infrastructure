local function text_format(symbol)
  local res = {}

  local round_start = { "", "SymbolUsageRounding" }
  local round_end = { "", "SymbolUsageRounding" }

  if symbol.references then
    local usage = symbol.references <= 1 and "usage" or "usages"
    local num = symbol.references == 0 and "no" or symbol.references
    table.insert(res, round_start)
    table.insert(res, { "󰌹 ", "SymbolUsageRef" })
    table.insert(res, { ("%s %s"):format(num, usage), "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  if symbol.definition then
    if #res > 0 then
      table.insert(res, { " ", "NonText" })
    end
    table.insert(res, round_start)
    table.insert(res, { "󰳽 ", "SymbolUsageDef" })
    table.insert(res, { symbol.definition .. " defs", "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  if symbol.implementation then
    if #res > 0 then
      table.insert(res, { " ", "NonText" })
    end
    table.insert(res, round_start)
    table.insert(res, { "󰡱 ", "SymbolUsageImpl" })
    table.insert(res, { symbol.implementation .. " impls", "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  return res
end

---@type LazyPluginSpec
return {
  "Wansmer/symbol-usage.nvim",
  -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
  event = utils.general.is_nightly() and "LspAttach" or "BufReadPre",
  ---@type UserOpts
  opts = {
    references = {
      enabled = true,
      include_declaration = false,
    },
    definition = {
      enabled = true,
    },
    implementation = {
      enabled = true,
    },
    vt_position = "above",
    text_format = text_format,
    request_pending_text = core.icons.ui.Ellipsis,
  },
  config = function(_, opts)
    ---@param name string
    local function h(name)
      return vim.api.nvim_get_hl(0, { name = name })
    end
    ---@param name string
    ---@param highlights { fg?: string, bg?: string }
    local function set_symbol_usage_highlight(name, highlights)
      vim.api.nvim_set_hl(
        0,
        "SymbolUsage" .. name,
        vim.tbl_deep_extend("force", {
          italic = true,
        }, highlights)
      )
    end
    set_symbol_usage_highlight("Rounding", {
      fg = h("CursorLine").bg,
    })
    set_symbol_usage_highlight("Content", {
      bg = h("CursorLine").bg,
      fg = h("Comment").fg,
    })
    set_symbol_usage_highlight("Ref", {
      fg = h("Function").fg,
      bg = h("CursorLine").bg,
    })
    set_symbol_usage_highlight("Def", {
      fg = h("Type").fg,
      bg = h("CursorLine").bg,
    })
    set_symbol_usage_highlight("Impl", {
      fg = h("@keyword").fg,
      bg = h("CursorLine").bg,
    })

    require("symbol-usage").setup(opts)
  end,
}
