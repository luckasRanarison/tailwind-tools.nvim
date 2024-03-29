local M = {}

local log = require("tailwind-tools.log")
local config = require("tailwind-tools.config")
local parsers = require("nvim-treesitter.parsers")

local supported_filetypes = {
  "html",
  "css",
  "php",
  "vue",
  "svelte",
  "astro",
  "htmldjango",
  "javascriptreact",
  "typescriptreact",
}

---@param bufnr number
---@param all boolean?
M.get_class_nodes = function(bufnr, all)
  local ft = vim.bo[bufnr].ft
  local filetypes = vim.tbl_extend("keep", config.options.custom_filetypes, supported_filetypes)
  local results = {}

  if not vim.tbl_contains(filetypes, ft) then return end

  local parser = parsers.get_parser(bufnr)

  if not parser then return log.warn("No parser available for " .. ft) end

  if all and vim.version().minor == 10 then parser:parse(true) end

  parser:for_each_tree(function(tree, lang_tree)
    local root = tree:root()
    local lang = lang_tree:lang()
    local query = vim.treesitter.query.get(lang, "class")

    if query then
      for _, match in query:iter_matches(root, bufnr, 0, -1, { all = true }) do
        results[#results + 1] = match[2][1] or match[2]
      end
    end
  end)

  return results
end

---@param node TSNode
---@param bufnr number
M.get_class_range = function(node, bufnr)
  local start_row, start_col, end_row, end_col = node:range()
  local children = node:named_children()

  if children[1] and vim.treesitter.get_node_text(children[1], bufnr) == "@apply" then
    start_row, start_col, _, _ = children[2]:range()
    _, _, end_row, end_col = children[#children]:range()
  end

  return start_row, start_col, end_row, end_col
end

return M
