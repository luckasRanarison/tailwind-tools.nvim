local M = {}

M.nvim_cmp_format = function()
  -- TODO
end

M.lspkind_format = function(entry, vim_item)
  if vim_item.kind == "Color" and entry.completion_item.documentation then
    local _, _, r, g, b =
        string.find(entry.completion_item.documentation, "^rgb%((%d+), (%d+), (%d+)")
    if r then
      local color = string.format("%02x%02x%02x", r, g, b)
      local group = "TailwindColor" .. color
      if vim.fn.hlID(group) < 1 then vim.api.nvim_set_hl(0, group, { fg = "#" .. color }) end
      vim_item.kind_hl_group = group
    end
  end
  return vim_item
end

return M
