local M = {}

local config = require("tailwind-tools.config")

---@param bufnr number
---@param client vim.lsp.Client
M.color_request = function(bufnr, client)
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  client.request("textDocument/documentColor", params, function(err, result, _, _)
    if err then
      vim.notify(err.message)
      return
    end

    if not vim.api.nvim_buf_is_valid(bufnr) then return end

    ---@type lsp.ColorInformation[]
    local colors = result
    vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)

    for _, color in pairs(colors) do
      local r = math.floor(color.color.red * 255)
      local g = math.floor(color.color.green * 255)
      local b = math.floor(color.color.blue * 255)
      local color_value = string.format("%02x%02x%02x", r, g, b)
      local group = "TailwindColor" .. color_value
      if vim.fn.hlID(group) < 1 then vim.api.nvim_set_hl(0, group, { fg = "#" .. color_value }) end

      vim.api.nvim_buf_set_extmark(
        bufnr,
        vim.g.tailwind_tools.color_ns,
        color.range.start.line,
        color.range.start.character,
        {
          virt_text = { { config.options.document_color.virtual_text, group } },
          virt_text_pos = "inline",
        }
      )
    end
  end, bufnr)
end

return M
