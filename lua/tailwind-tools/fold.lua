local config = require("tailwind-tools.config")

local M = {}

local html_query = [[
  (attribute
    (attribute_name) @_attribute_name
    (#eq? @_attribute_name "class")
    (quoted_attribute_value
      (attribute_value) @_attribute_value))
]]

---@param bufnr number
M.set_conceal = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "html")
  local tree = parser:parse()
  local root = tree[1]:root()
  local query = vim.treesitter.query.parse("html", html_query)
  local iter = query:iter_matches(root, bufnr, root:start(), root:end_(), { all = true })

  for _, match in iter do
    local start_row, start_col, end_row, end_col = match[2][1]:range()
    vim.api.nvim_buf_set_extmark(bufnr, vim.g.tailwind_tools.namespace, start_row, start_col, {
      end_line = end_row,
      end_col = end_col,
      conceal = config.options.conceal.symbol,
      hl_group = "TailwindConceal",
    })
  end
end

M.attach_autocmd = function()
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("tailwind_conceal", {}),
    callback = function(args) M.set_conceal(args.buf) end,
  })
end

return M
