local M = {}

local lang_map = {
  html = { "html", "php" },
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

return M
