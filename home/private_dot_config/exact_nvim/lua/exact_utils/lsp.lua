--------------------------------------------------------------------------------
--  LSP UTILS
--------------------------------------------------------------------------------
---@class utils.lsp
local M = {}

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

    if vim.tbl_islist(result) then
      vim.lsp.util.jump_to_location(result[1], "utf-8")
    else
      vim.lsp.util.jump_to_location(result, "utf-8")
    end
  end
end

---@param opts? lsp.Client.filter
local function get_clients(opts)
  local ret = {} ---@type lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ---@param client lsp.Client
      ret = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

---@param method string
local function client_supports_method(method, buffer)
  method = method:find("/") and method or "textDocument/" .. method
  local clients = get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

---@param mappings utils.mappings.mappings_spec
---
--- If client doesn't support method, remove it from mappings
---
--- NOTE: This mutates mappings!
function M.remove_unsupported_methods(bufnr, mappings)
  for _, mode in pairs(mappings) do
    for mapping, mapping_info in pairs(mode) do
      if mapping_info.has and not client_supports_method(mapping_info.has, bufnr) then
        mode[mapping] = nil
      else
        mapping_info.has = nil
      end
    end
  end
end

---@param args { data: { client_id: integer }, buf: integer }
---
--- The following two autocommands are used to highlight references of the
--- word under your cursor when your cursor rests there for a little while.
--- When you move your cursor, the highlights will be cleared (the second autocommand).
function M.set_document_highlight(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client and client.server_capabilities.documentHighlightProvider then
    core.auto_cmds({
      {
        { "CursorHold", "CursorHoldI" },
        {
          group = "lsp_document_highlight",
          buffer = args.buf,
          callback = vim.lsp.buf.document_highlight,
        },
      },
      {
        { "CursorMoved", "CursorMovedI" },
        {
          group = "lsp_document_highlight",
          buffer = args.buf,
          callback = vim.lsp.buf.clear_references,
        },
      },
    })
  end
end

---@param from string
---@param to string
function M.on_rename(from, to)
  local clients = get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      ---@diagnostic disable-next-line: invisible
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
