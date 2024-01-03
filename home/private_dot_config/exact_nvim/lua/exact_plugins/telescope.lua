---@type LazyPluginSpec
return {
  "nvim-telescope/telescope.nvim",
  keys = core.lazy_map({
    n = {
      ["<leader>fw"] = {
        require("lazyvim.util").telescope("live_grep"),
        "Grep (root dir)",
      },
      ["<leader>/"] = { false },
      ["<leader>,"] = { false },
      ["<leader>fp"] = {
        function()
          require("telescope.builtin").find_files({
            cwd = require("lazy.core.config").options.root,
          })
        end,
        "Find Plugin File",
      },
      ["<leader>fl"] = {
        function()
          local files = {} ---@type table<string, string>
          for _, plugin in pairs(require("lazy.core.config").plugins) do
            repeat
              if plugin._.module then
                local info = vim.loader.find(plugin._.module)[1]
                if info then
                  files[info.modpath] = info.modpath
                end
              end
              plugin = plugin._.super
            until not plugin
          end
          require("telescope.builtin").live_grep({
            default_text = "/",
            search_dirs = vim.tbl_values(files),
          })
        end,
        "Find Lazy Plugin Spec",
      },
    },
  }),
  opts = function(_, opts)
    opts.defaults = opts.defaults or {}
    opts.defaults.prompt_prefix = core.icons.ui.Telescope .. " "
    opts.defaults.sorting_strategy = "ascending"
    opts.defaults.layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.5,
      },
      vertical = {
        mirror = false,
      },
      width = core.config.ui.width,
      height = core.config.ui.height,
      preview_cutoff = 120,
    }

    -- Load extensions
    opts.load_extensions = opts.load_extensions or {}
    for extension, _ in pairs(opts.load_extensions) do
      require("telescope").load_extension(extension)
    end
  end,
}
