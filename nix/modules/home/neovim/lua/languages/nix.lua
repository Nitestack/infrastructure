-- ╭─────────────────────────────────────────────────────────╮
-- │ Nix                                                     │
-- ╰─────────────────────────────────────────────────────────╯

local nix_flake_root = "~/.dotfiles/nix"

return utils.plugin.get_language_spec({
  treesitter = "nix",
  lsp = {
    servers = {
      nixd = {
        settings = {
          nixd = {
            nixpkgs = {
              expr = "(builtins.getFlake (toString ~/.dotfiles/nix)).inputs.nixpkgs",
            },
            formatting = {
              command = { "nixfmt" },
            },
            options = {
              nixos = {
                expr = "(builtins.getFlake (toString " .. nix_flake_root .. ")).nixosConfigurations.nixstation.options",
              },
              ["nix-darwin"] = {
                expr = "(builtins.getFlake (toString "
                  .. nix_flake_root
                  .. ")).darwinConfigurations.macstation.options.wsl",
              },
              ["nix-wsl"] = {
                expr = "(builtins.getFlake (toString " .. nix_flake_root .. ")).nixosConfigurations.wslstation.options",
              },
              ["home-manager"] = {
                expr = "(builtins.getFlake (toString "
                  .. nix_flake_root
                  .. ")).nixosConfigurations.nixstation.options.home-manager.users.type.getSubOptions []",
              },
            },
          },
        },
        cmd = { "nixd", "--semantic-tokens=true" },
      },
    },
  },
  linter = {
    linters_by_ft = {
      ["nix"] = { "statix" },
    },
  },
})
