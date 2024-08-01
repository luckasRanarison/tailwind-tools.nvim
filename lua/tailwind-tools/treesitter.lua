local M = {}

local log = require("tailwind-tools.log")

---@param bufnr number
---@param ft string
local function find_class_nodes(bufnr, ft)
  local results = {}
  local parser = vim.treesitter.get_parser(bufnr)

  if not parser then return log.error("No parser available for " .. ft) end
  if vim.version().minor >= 10 then parser:parse(true) end

  parser:for_each_tree(function(tree, lang_tree)
    local root = tree:root()
    local lang = lang_tree:lang()
    local query = vim.treesitter.query.get(lang, "class")

    if query then
      ---@diagnostic disable-next-line: redundant-parameter
      for id, node in query:iter_captures(root, bufnr, 0, -1, { all = true }) do
        if query.captures[id] == "tailwind" then results[#results + 1] = node end
      end
    end
  end)

  return results
end

---@param node TSNode
---@param bufnr number
local function get_class_range(node, bufnr)
  local start_row, start_col, end_row, end_col = node:range()
  local children = node:named_children()

  -- A special case for extracting postcss class range
  if children[1] and vim.treesitter.get_node_text(children[1], bufnr) == "@apply" then
    start_row, start_col, _, _ = children[2]:range()
    _, _, end_row, end_col = children[#children]:range()
  end

  return start_row, start_col, end_row, end_col
end

---@param bufnr number
---@param ft string
M.find_class_ranges = function(bufnr, ft)
  local nodes = find_class_nodes(bufnr, ft)

  if not nodes then return end

  local results = {}

  for _, node in pairs(nodes) do
    local sr, sc, er, ec = get_class_range(node, bufnr)
    results[#results + 1] = { sr, sc, er, ec }
  end

  return results
end

return M
