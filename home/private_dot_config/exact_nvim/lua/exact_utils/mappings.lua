--------------------------------------------------------------------------------
--  MAPPING UTILS
--------------------------------------------------------------------------------
---@class utils.mappings
local M = {}

---@class utils.mappings.mappings_spec
---@field n?   table<string, utils.mappings.mapping> Normal Mode keymaps
---@field x?   table<string, utils.mappings.mapping> Visual Mode keymaps
---@field s?   table<string, utils.mappings.mapping> Select Mode keymaps
---@field v?   table<string, utils.mappings.mapping> Visual + Select Mode keymaps
---@field o?   table<string, utils.mappings.mapping> Operator-Pending Mode keymaps
---@field i?   table<string, utils.mappings.mapping> Insert Mode keymaps
---@field c?   table<string, utils.mappings.mapping> Command-Line Mode keymaps
---@field l?   table<string, utils.mappings.mapping> Insert + Command-Line + Lang-Arg Mode keymaps
---@field t?   table<string, utils.mappings.mapping> Terminal Mode keymaps
---@field ['"!"']? table<string, utils.mappings.mapping> Insert + Command-Line Mode keymaps
---@field ['""']? table<string, utils.mappings.mapping> Normal, Visual and Operating-Pending Mode keymaps
---@field prefix? string Prefix for all keymaps

---@class utils.mappings.lazy_mappings_spec
---@field n?   table<string, utils.mappings.lazy_mapping> Normal Mode keymaps
---@field x?   table<string, utils.mappings.lazy_mapping> Visual Mode keymaps
---@field s?   table<string, utils.mappings.lazy_mapping> Select Mode keymaps
---@field v?   table<string, utils.mappings.lazy_mapping> Visual + Select Mode keymaps
---@field o?   table<string, utils.mappings.lazy_mapping> Operator-Pending Mode keymaps
---@field i?   table<string, utils.mappings.lazy_mapping> Insert Mode keymaps
---@field c?   table<string, utils.mappings.lazy_mapping> Command-Line Mode keymaps
---@field l?   table<string, utils.mappings.lazy_mapping> Insert + Command-Line + Lang-Arg Mode keymaps
---@field t?   table<string, utils.mappings.lazy_mapping> Terminal Mode keymaps
---@field ['"!"']? table<string, utils.mappings.lazy_mapping> Insert + Command-Line Mode keymaps
---@field ['""']? table<string, utils.mappings.lazy_mapping> Normal, Visual and Operating-Pending Mode keymaps
---@field prefix? string Prefix for all keymaps

---@class utils.mappings.mapping
---@field [1] string|fun()
---@field [2]? string
---@field opts? utils.mappings.mapping_opts

---@class utils.mappings.lazy_mapping
---@field [1] string|fun()|false
---@field [2]? string
---@field opts? utils.mappings.mapping_opts

---@class utils.mappings.mapping_opts:vim.api.keyset.keymap
---@field remap? boolean Inverse of `noremap`
---@field buffer? integer|boolean|nil Specify the buffer that the keymap will be effective in. If 0 or true, the current buffer will be used
---@field ft? (string|string[])? Specify the filetype that the keymap will be effective in

---Loads a single mapping (with `vim.keymap.set`)
---@param mode string|string[]
---@param lhs string
---@param mappings_spec utils.mappings.mapping
function M.single_map(mode, lhs, mappings_spec)
  local opts = vim.tbl_deep_extend(
    "force",
    mappings_spec[2] ~= nil and { desc = mappings_spec[2] } or {},
    mappings_spec.opts or {}
  )
  vim.keymap.set(mode, lhs, mappings_spec[1], opts)
end

---Loads a single mapping for `lazy.nvim` plugin spec
---@param mode string|string[]
---@param lhs string
---@param mappings_spec utils.mappings.lazy_mapping
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
---@param mappings utils.mappings.mappings_spec
---@param mapping_opts? utils.mappings.mapping_opts
function M.map(mappings, mapping_opts)
  local prefix = mappings.prefix or ""
  mappings.prefix = nil

  for mode, mode_mappings in pairs(mappings) do
    local default_opts = vim.tbl_deep_extend("force", { mode = mode }, mapping_opts or {})

    for mapping, mapping_info in pairs(mode_mappings) do
      local opts = vim.tbl_deep_extend("force", default_opts, mapping_info.opts or {})

      mapping_info.opts, opts.mode = nil, nil
      opts.desc = mapping_info[2]

      if type(mapping) == "string" then
        vim.keymap.set(mode, prefix .. mapping, mapping_info[1], opts)
      else
        for _, keymap in ipairs(mapping) do
          vim.keymap.set(mode, prefix .. keymap, mapping_info[1], opts)
        end
      end
    end
  end
end

---Loads mappings for `lazy.nvim` plugin spec
---@param mappings utils.mappings.lazy_mappings_spec
---@param mapping_opts? utils.mappings.mapping_opts
---@return LazyKeysSpec[]
function M.lazy_map(mappings, mapping_opts)
  local lazy_mappings = {}

  local prefix = mappings.prefix or ""
  mappings.prefix = nil

  for mode, mode_mappings in pairs(mappings) do
    for mapping, mapping_info in pairs(mode_mappings) do
      local opts = vim.tbl_deep_extend("force", mapping_opts or {}, mapping_info.opts or {})

      opts.desc = mapping_info[2]
      opts.mode = mode

      if type(mapping) == "string" then
        table.insert(
          lazy_mappings,
          vim.tbl_extend("force", opts, {
            prefix .. mapping,
            mapping_info[1],
          })
        )
      else
        for _, keymap in ipairs(mapping) do
          table.insert(
            lazy_mappings,
            vim.tbl_extend("force", opts, {
              prefix .. keymap,
              mapping_info[1],
            })
          )
        end
      end
    end
  end

  return lazy_mappings
end

return M
