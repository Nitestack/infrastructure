--------------------------------------------------------------------------------
--  All
--------------------------------------------------------------------------------
local function with_cmt(cmt)
  return string.format(vim.bo.commentstring, cmt)
end

---@diagnostic disable: undefined-global
return {
  s(
    { trig = "td", name = "TODO" },
    fmt("{} {}", {
      d(1, function()
        return sn(nil, {
          c(1, {
            t(with_cmt("TODO:")),
            t(with_cmt("FIXME:")),
            t(with_cmt("HACK:")),
            t(with_cmt("BUG:")),
          }),
        })
      end),
      i(0),
    })
  ),
  s(
    { trig = "hr", name = "Header" },
    fmt(
      [[
        {1}
        {2} {3}
        {1}
        {4}
          ]],
      {
        f(utils.snippet.header_lines),
        f(utils.snippet.header_title),
        i(1, "HEADER"),
        i(0),
      }
    )
  ),
  -- Create a new snippet, that provides a modeline comment for a filetype
  s(
    { trig = "ft", name = "Vi modeline: set filetype" },
    fmt([[{}: set ft={} {}]], {
      f(function()
        return with_cmt("vim")
      end),
      d(1, function()
        return sn("", { i(1, vim.fn.fnamemodify(vim.fn.expand("%"), ":e")) })
      end),
      i(0),
    })
  ),
}
