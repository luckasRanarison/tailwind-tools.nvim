local M = {}

local log = require("tailwind-tools.log")

---@class TailwindTools.CaptureMetadata
---@field start? string
---@field end? string

---@param node TSNode
---@param metadata TailwindTools.CaptureMetadata
---@param capture_id "tailwind" | "tailwind.inner"
local function get_class_range(node, metadata, capture_id)
  local s_row, s_col, e_row, e_col = node:range()

  if capture_id == "tailwind.inner" then
    local children = node:named_children()
    local m_start = metadata.start and tonumber(metadata.start) or 0
    local m_end = metadata["end"] and tonumber(metadata["end"]) or 0

    s_row, s_col, _, _ = children[m_start + 1]:range()
    _, _, e_row, e_col = children[#children + m_end]:range()
  end

  return { s_row, s_col, e_row, e_col }
end

---@param bufnr number
---@param ft string
---@return number[][]
M.find_class_ranges = function(bufnr, ft)
  local results = {}
  local parser = vim.treesitter.get_parser(bufnr)

  if not parser then
    log.error("No parser available for " .. ft)
    return results
  end

  if vim.version().minor >= 10 then parser:parse(true) end

  parser:for_each_tree(function(tree, lang_tree)
    local root = tree:root()
    local lang = lang_tree:lang()
    local query = vim.treesitter.query.get(lang, "class")

    if not query then return end

    ---@diagnostic disable-next-line: redundant-parameter
    for id, node, metadata in query:iter_captures(root, bufnr, 0, -1, { all = true }) do
      local capture_id = query.captures[id]
      local capture_metadata = metadata[id] or {}

      if capture_id:find("tailwind") then
        results[#results + 1] = get_class_range(node, capture_metadata, capture_id)
      end
    end
  end)

  return results
end

return M
