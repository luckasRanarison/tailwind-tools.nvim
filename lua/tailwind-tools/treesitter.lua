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

local query_map = {
  html = [[
    (attribute
      (attribute_name) @_attribute_name
      (#eq? @_attribute_name "class")
      (quoted_attribute_value
        (attribute_value) @_attribute_value))
  ]],
  tsx = [[
    (jsx_attribute
    (property_identifier) @_attribute_name
    (#eq? @_attribute_name "className")
    [
      (string
        (string_fragment) @_attribute_value)
      (jsx_expression
        (_) @_attribute_value)
    ])
  ]],
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
    local query = vim.treesitter.query.parse(lang, query_map[lang])
    return query:iter_matches(root, bufnr, root:start(), root:end_(), { all = true })
  end
end

return M
