local M = {}

M.lang = {
  html = { "html", "php" },
  tsx = {
    "astro",
    "vue",
    "svete",
    "javascriptreact",
    "typescriptreact",
  },
}

M.query = {
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

return M
