--------------------------------------------------------------------------------
--  LOADER FUNCTIONS
--------------------------------------------------------------------------------
local M = {}

---@param config { options?: vim.opt, config?: fun(), mappings?: Mappings, mapping_opts?: KeymapOpts }
function M.load_ftplugin(config)
  if config.options then
    for k, v in pairs(config.options) do
      vim.wo[k] = v
    end
  end
  if config.config then
    config.config()
  end
  if config.mappings then
    require("utils.mappings").map(config.mappings, config.mapping_opts)
  end
end

---@param opts LazyConfig
function M.load_plugins(opts)
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

  require("lazy").setup(opts)
end

---@param config SettingsConfig
---@param filetypes vim.filetype.add.filetypes
function M.load_settings(config, filetypes)
  for k, v in pairs(config.options) do
    vim.opt[k] = v
  end

  for k, v in pairs(config.globals) do
    vim.g[k] = v
  end

  for _, provider in ipairs(config.disabled_providers) do
    vim.g["loaded_" .. provider .. "_provider"] = 0
  end

  config.run()

  vim.filetype.add(filetypes)
end

---@param config MappingsConfig
function M.load_mappings(config)
  require("utils.mappings").map(config.mappings, config.mapping_opts)
  require("utils.mappings").disable_mapping(config.unmappings)
end

---@param config CommandConfiguration
function M.load_commands(config)
  require("utils.cmds").auto_cmds(config.auto_cmds, config.auto_cmd_opts, config.au_group_opts)
  require("utils.cmds").user_cmds(config.user_cmds, config.user_cmd_opts)
end

return M
