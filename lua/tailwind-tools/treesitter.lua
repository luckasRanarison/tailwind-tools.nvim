local M = {}

local lang_map = {
  html = { "html", "php" },
  css = { "css", "sass", "scss" },
  tsx = {
    "astro",
    "vue",
    "svete",
    "javascriptreact",
    "typescriptreact",
  },
}

M.get_class_iter = function(bufnr)
  local lang = nil

  for key, filetypes in pairs(lang_map) do
    if vim.tbl_contains(filetypes, vim.bo.ft) then lang = key end
  end

  if lang then
    local parser = vim.treesitter.get_parser(bufnr, lang)
    local tree = parser:parse()
    local root = tree[1]:root()
    local query = vim.treesitter.query.get(lang, "class")
    return query:iter_matches(root, bufnr, root:start(), root:end_(), { all = true })
  end
end

---@param node TSNode
---@param bufnr number
M.get_node_range = function(node, bufnr)
  local start_row, start_col, end_row, end_col = node:range()
  local children = node:named_children()

  if children[1] and vim.treesitter.get_node_text(children[1], bufnr) == "@apply" then
    start_row, start_col, end_row, _ = children[2]:range()
    _, _, _, end_col = children[#children]:range()
  end

  return start_row, start_col, end_row, end_col
end

return M
