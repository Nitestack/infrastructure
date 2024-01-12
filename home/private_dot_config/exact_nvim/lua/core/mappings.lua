--------------------------------------------------------------------------------
--  MAPPINGS & UNMAPPINGS
--------------------------------------------------------------------------------

---@class MappingsConfig
---@field mappings Mappings
---@field unmappings DisableMappings
---@field mapping_opts KeymapOpts

--------------------------------------------------------------------------------
--  Mappings
--------------------------------------------------------------------------------

---@type MappingsConfig
local M = {}

M.mappings = {
  [{ "n", "v" }] = {
    ["<leader>d"] = {
      [["_d]],
      "Delete into void register",
    },
  },
}

-- TLDR: Conditionally modify character at end of line
-- Description:
-- This function takes a delimiter character and:
--   * removes that character from the end of the line if the character at the end
--     of the line is that character
--   * removes the character at the end of the line if that character is a
--     delimiter that is not the input character and appends that character to
--     the end of the line
--   * adds that character to the end of the line if the line does not end with
--     a delimiter
-- Delimiters:
-- - ","
-- - ";"
---@param character string
---@return function
local function modify_line_end_delimiter(character)
  local delimiters = { ",", ";" }
  return function()
    local line = vim.api.nvim_get_current_line()
    local last_char = line:sub(-1)
    if last_char == character then
      vim.api.nvim_set_current_line(line:sub(1, #line - 1))
    elseif vim.tbl_contains(delimiters, last_char) then
      vim.api.nvim_set_current_line(line:sub(1, #line - 1) .. character)
    else
      vim.api.nvim_set_current_line(line .. character)
    end
  end
end

M.mappings.n = {
  -- End of line
  ["<leader>,"] = {
    modify_line_end_delimiter(","),
    "Modify line end delimiter",
  },
  ["<leader>;"] = {
    modify_line_end_delimiter(";"),
    "Modify line end delimiter",
  },
  -- Windows
  ["<leader>wh"] = {
    "<C-W>t <C-W>K",
    "Change two horizontal windows to vertical",
  },
  ["<leader>wv"] = {
    "<C-W>t <C-W>H",
    "Change two vertical windows to horizontal",
  },
  -- Quotes
  ["<leader>\""] = {
    [[ciw"<c-r>""<esc>]],
    "Surround with double quotes",
  },
  ["<leader>'"] = {
    [[ciw'<c-r>"'<esc>]],
    "Surround with single quotes",
  },
  ["<leader>`"] = {
    [[ciw`<c-r>"`<esc>]],
    "Surround with backticks",
  },
  ["<leader>)"] = {
    [[ciw(<c-r>")<esc>]],
    "Surround with parentheses",
  },
  ["<leader>}"] = {
    [[ciw{<c-r>"}<esc>]],
    "Surround with braces",
  },
  -- General
  ["x"] = { "\"_x" },
}

M.mappings.v = {
  -- Indent
  ["<Tab>"] = {
    ">gv",
    "Indent right",
  },
  ["<S-Tab>"] = {
    "<gv",
    "Indent left",
  },
  -- Quotes
  ["<leader>\""] = {
    [[c"<c-r>""<esc>]],
    "Surround selection with double quotes",
  },
  ["<leader>'"] = {
    [[c'<c-r>"'<esc>]],
    "Surround selection with single quotes",
  },
  ["<leader>`"] = {
    [[c`<c-r>"`<esc>]],
    "Surround selection with backticks",
  },
  ["<leader>)"] = {
    [[c(<c-r>")<esc>]],
    "Surround selection with parentheses",
  },
  ["<leader>}"] = {
    [[c{<c-r>"}<esc>]],
    "Surround selection with braces",
  },
  -- End of line
  ["$"] = {
    "g_",
    "Go to end of line (ignore whitespace)",
  },
}

M.mappings.x = {
  -- Macros
  ["@"] = {
    function()
      vim.ui.input({ prompt = "Macro Register: " }, function(reg)
        vim.cmd("'<,'>normal @" .. reg)
      end)
    end,
    "Execute macro over visual range",
    opts = {
      silent = false,
    },
  },
}

M.mappings.t = {
  ["<Esc>"] = {
    "<C-\\><C-n>",
    "Enter Normal Mode",
  },
}

--------------------------------------------------------------------------------
--  Unmappings
--------------------------------------------------------------------------------
M.unmappings = {
  n = {
    -- Buffers
    "<leader>bb",
    "<leader>`",
    -- LazyVim terminal
    "<leader>ft",
    "<leader>fT",
    "<C-/>",
    "<C-_>",
  },
  v = {
    -- Indenting
    "<",
    ">",
  },
  -- LazyVim terminal
  t = {
    "<esc><esc>",
    "<C-/>",
    "<C-_>",
  },
}

if require("core.config").ui.disable_bufferline then
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.list_extend(M.unmappings.n, { "<S-h>", "<S-l>" })
end

M.mapping_opts = {
  silent = true,
  noremap = true,
}

return M
