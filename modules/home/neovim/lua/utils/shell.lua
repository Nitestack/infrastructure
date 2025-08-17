-- ╭─────────────────────────────────────────────────────────╮
-- │ Shell Utils                                             │
-- ╰─────────────────────────────────────────────────────────╯

---@class utils.shell
local M = {}

function M.setup_nushell()
  vim.opt.shellcmdflag = "--login --stdin --no-newline -c"
  vim.opt.shellpipe =
    "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"
  vim.opt.shellquote = ""
  vim.opt.shellredir = "out+err> %s"
  vim.opt.shelltemp = false
  vim.opt.shellxescape = ""
  vim.opt.shellxquote = ""
end

function M.setup_posix_shell()
  vim.opt.shellcmdflag = "-c"
  vim.opt.shellpipe = "2>&1 | tee"
  vim.opt.shellquote = ""
  vim.opt.shellredir = ">%s 2>&1"
  vim.opt.shelltemp = true
  vim.opt.shellxescape = ""
  vim.opt.shellxquote = ""
end

function M.is_nushell()
  return vim.opt.shell:get():match("nu$") ~= nil
end

return M
