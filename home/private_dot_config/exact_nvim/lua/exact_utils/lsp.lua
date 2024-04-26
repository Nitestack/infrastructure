--------------------------------------------------------------------------------
--  LSP UTILS
--------------------------------------------------------------------------------
---@class utils.lsp
local M = {}

---@param method string
local function client_supports_method(method, buffer)
  method = method:find("/") and method or "textDocument/" .. method
  local clients = vim.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

---@param capabilities? table
function M.get_capabilities(capabilities)
  local cmp_nvim_lsp_exists, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  return vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    cmp_nvim_lsp_exists and cmp_nvim_lsp.default_capabilities() or {},
    capabilities or {}
  )
end

function M.set_handlers()
  -- Jump directly to the first available definition every time.
  vim.lsp.handlers["textDocument/definition"] = function(_, result)
    if not result or vim.tbl_isempty(result) then
      return
    end

    if vim.islist(result) then
      vim.lsp.util.jump_to_location(result[1], "utf-8")
    else
      vim.lsp.util.jump_to_location(result, "utf-8")
    end
  end
end

---@param client vim.lsp.Client
---@param buffer integer
function M.set_code_lens(client, buffer)
  if vim.lsp.codelens and client.supports_method("textDocument/codeLens") then
    vim.lsp.codelens.refresh({ bufnr = buffer })
    core.auto_cmds({
      {
        { "BufEnter", "CursorHold", "InsertLeave" },
        {
          buffer = buffer,
          callback = function(a)
            vim.lsp.codelens.refresh({ bufnr = a.buf })
          end,
        },
      },
    })
  end
end

---@param client vim.lsp.Client
---@param buffer integer
function M.set_semantic_tokens(client, buffer)
  if
    vim.lsp.semantic_tokens
    and client.supports_method("textDocument/semanticTokens/full")
    and vim.b[buffer].semantic_tokens == nil
  then
    vim.b[buffer].semantic_tokens = true
  end
end

---@param client vim.lsp.Client
---@param buffer integer
--- The following two autocommands are used to highlight references of the
--- word under your cursor when your cursor rests there for a little while.
--- When you move your cursor, the highlights will be cleared (the second autocommand).
function M.set_document_highlight(client, buffer)
  if client.server_capabilities.documentHighlightProvider then
    core.auto_cmds({
      {
        { "CursorHold", "CursorHoldI" },
        {
          group = "lsp_document_highlight",
          buffer = buffer,
          callback = vim.lsp.buf.document_highlight,
        },
      },
      {
        { "CursorMoved", "CursorMovedI" },
        {
          group = "lsp_document_highlight",
          buffer = buffer,
          callback = vim.lsp.buf.clear_references,
        },
      },
    })
  end
end

---@param mappings core.mappings.lsp_mappings
---@param buffer integer
function M.attach_mappings(mappings, buffer)
  for _, mode_mappings in
    pairs(mappings --[[@as table<string|string[], table<string|string[], utils.mappings.mapping>>>>]])
  do
    for mapping, mapping_info in pairs(mode_mappings) do
      if mapping_info.has and not client_supports_method(mapping_info.has, buffer) then
        mode_mappings[mapping] = nil
      else
        mapping_info.has = nil
      end
    end
  end

  utils.mappings.map(mappings, { buffer = buffer, silent = true })
end

---@param from string
---@param to string
function M.on_rename(from, to)
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      local resp = client.request_sync("workspace/willRenameFiles", {
        files = {
          {
            oldUri = vim.uri_from_fname(from),
            newUri = vim.uri_from_fname(to),
          },
        },
      }, 1000, 0)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end
end

return M
