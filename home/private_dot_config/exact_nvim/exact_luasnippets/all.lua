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
}
