--------------------------------------------------------------------------------
--  MAPPING UTILS
--------------------------------------------------------------------------------
local M = {}

---@class Mappings
---@field n?   table<string, KeymapConfig> Normal Mode keymaps
---@field x?   table<string, KeymapConfig> Visual Mode keymaps
---@field s?   table<string, KeymapConfig> Select Mode keymaps
---@field v?   table<string, KeymapConfig> Visual + Select Mode keymaps
---@field o?   table<string, KeymapConfig> Operator-Pending Mode keymaps
---@field i?   table<string, KeymapConfig> Insert Mode keymaps
---@field c?   table<string, KeymapConfig> Command-Line Mode keymaps
---@field l?   table<string, KeymapConfig> Insert + Command-Line + Lang-Arg Mode keymaps
---@field t?   table<string, KeymapConfig> Terminal Mode keymaps
---@field ['"!"']? table<string, KeymapConfig> Insert + Command-Line Mode keymaps
---@field ['""']? table<string, KeymapConfig> Normal, Visual and Operating-Pending Mode keymaps

---@class DisableMappings
---@field n? DisableKeymapConfig Normal Mode keymaps
---@field x? DisableKeymapConfig Visual Mode keymaps
---@field s? DisableKeymapConfig Select Mode keymaps
---@field v? DisableKeymapConfig Visual + Select Mode keymaps
---@field o? DisableKeymapConfig Operator-Pending Mode keymaps
---@field i? DisableKeymapConfig Insert Mode keymaps
---@field c? DisableKeymapConfig Command-Line Mode keymaps
---@field l? DisableKeymapConfig Insert + Command-Line + Lang-Arg Mode keymaps
---@field t? DisableKeymapConfig Terminal Mode keymaps
---@field ['"!"']? DisableKeymapConfig Insert + Command-Line Mode keymaps
---@field ['""']? DisableKeymapConfig Normal, Visual and Operating-Pending Mode keymaps

---@class LazyMappings
---@field n?   table<string, LazyKeymapConfig> Normal Mode keymaps
---@field x?   table<string, LazyKeymapConfig> Visual Mode keymaps
---@field s?   table<string, LazyKeymapConfig> Select Mode keymaps
---@field v?   table<string, LazyKeymapConfig> Visual + Select Mode keymaps
---@field o?   table<string, LazyKeymapConfig> Operator-Pending Mode keymaps
---@field i?   table<string, LazyKeymapConfig> Insert Mode keymaps
---@field c?   table<string, LazyKeymapConfig> Command-Line Mode keymaps
---@field l?   table<string, LazyKeymapConfig> Insert + Command-Line + Lang-Arg Mode keymaps
---@field t?   table<string, LazyKeymapConfig> Terminal Mode keymaps
---@field ['"!"']? table<string, LazyKeymapConfig> Insert + Command-Line Mode keymaps
---@field ['""']? table<string, LazyKeymapConfig> Normal, Visual and Operating-Pending Mode keymaps

---@class KeymapConfig
---@field [1] string|fun()
---@field [2]? string
---@field opts? KeymapOpts

---@class LazyKeymapConfig
---@field [1]? string|fun()|false
---@field [2]? string
---@field opts? KeymapOpts

---@alias DisableKeymapConfig string|string[]

---@class KeymapOpts
---@field nowait? boolean If true, once the `lhs` is matched, the `rhs` will be executed
---@field expr? boolean Specify whether the `rhs` is an expression to be evaluated or not (default false)
---@field silent? boolean Specify whether `rhs` will be echoed on the command line
---@field unique? boolean Specify whether not to map if there exists a keymap with the same `lhs`
---@field script? boolean
---@field noremap? boolean Specify whether the `rhs` will execute user-defined keymaps if it matches some `lhs` or not
---@field remap? boolean inverse of `noremap`
---@field replace_keycodes? boolean Only effective when `expr` is **true**, specify whether to replace keycodes in the resuling string
---@field callback? function Lua function to call when the mapping is executed
---@field buffer? integer|boolean|nil Specify the buffer that the keymap will be effective in. If 0 or true, the current buffer will be used

---Loads a single mapping (with `vim.keymap.set`)
---@param mode string|string[]
---@param lhs string
---@param mappings_spec KeymapConfig
function M.single_map(mode, lhs, mappings_spec)
  local opts = vim.tbl_deep_extend("force", { mode = mode, desc = mappings_spec[2] }, mappings_spec.opts or {})
  vim.keymap.set(mode, lhs, mappings_spec[1], opts)
end

---Loads a single mapping for `lazy.nvim` plugin spec
---@param mode string|string[]
---@param lhs string
---@param mappings_spec LazyKeymapConfig
function M.single_lazy_map(mode, lhs, mappings_spec)
  local opts = vim.tbl_deep_extend("force", { mode = mode, desc = mappings_spec[2] }, mappings_spec.opts or {})
  ---@type LazyKeysSpec[]
  return {
    vim.tbl_extend("force", opts, {
      lhs,
      mappings_spec[1],
    }),
  }
end

---Loads mappings (with `vim.keymap.set`)
---@param mappings Mappings
---@param mapping_opts? KeymapOpts
function M.map(mappings, mapping_opts)
  for mode, mode_mappings in pairs(mappings) do
    local default_opts = vim.tbl_deep_extend("force", { mode = mode }, mapping_opts or {})

    for mapping, mapping_info in pairs(mode_mappings) do
      local opts = vim.tbl_deep_extend("force", default_opts, mapping_info.opts or {})

      mapping_info.opts, opts.mode = nil, nil
      opts.desc = mapping_info[2]

      if type(mapping) == "string" then
        vim.keymap.set(mode, mapping, mapping_info[1], opts)
      else
        for _, keymap in ipairs(mapping) do
          vim.keymap.set(mode, keymap, mapping_info[1], opts)
        end
      end
    end
  end
end

---Loads mappings for `lazy.nvim` plugin spec
---@param mappings LazyMappings
---@param mapping_opts? KeymapOpts
---@return LazyKeysSpec[]
function M.lazy_map(mappings, mapping_opts)
  local lazy_mappings = {}

  for mode, mode_mappings in pairs(mappings) do
    for mapping, mapping_info in pairs(mode_mappings) do
      local opts = vim.tbl_deep_extend("force", mapping_opts or {}, mapping_info.opts or {})

      ---@diagnostic disable-next-line: inject-field
      opts.desc = mapping_info[2]
      ---@diagnostic disable-next-line: inject-field
      opts.mode = mode

      if type(mapping) == "string" then
        table.insert(
          lazy_mappings,
          vim.tbl_extend("force", opts, {
            mapping,
            mapping_info[1],
          })
        )
      else
        for _, keymap in ipairs(mapping) do
          table.insert(
            lazy_mappings,
            vim.tbl_extend("force", opts, {
              keymap,
              mapping_info[1],
            })
          )
        end
      end
    end
  end

  return lazy_mappings
end

---Disables mappings (with `vim.keymap.del`)
---@param mappings DisableMappings
function M.disable_mapping(mappings)
  for mode, mode_mappings in pairs(mappings) do
    if type(mode_mappings) == "string" then
      vim.keymap.del(mode, mode_mappings)
    else
      for _, mapping in ipairs(mode_mappings) do
        vim.keymap.del(mode, mapping)
      end
    end
  end
end

return M
