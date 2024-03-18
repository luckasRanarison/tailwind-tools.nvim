local M = {}

local utils = require("tailwind-tools.utils")
local config = require("tailwind-tools.config")
local conceal = require("tailwind-tools.conceal")

local color_events = {
  "BufEnter",
  "TextChanged",
  "TextChangedI",
  "CursorMoved",
}

---@param bufnr number
---@param range lsp.Range
---@param hl_group string
local set_extmark = function(bufnr, range, hl_group)
  vim.api.nvim_buf_set_extmark(
    bufnr,
    vim.g.tailwind_tools.color_ns,
    range.start.line,
    range.start.character,
    {
      virt_text = { { config.options.document_color.inline_symbol, hl_group } },
      virt_text_pos = "inline",
    }
  )
end

---@param bufnr number
---@param client vim.lsp.Client
local color_request = function(bufnr, client)
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  client.request("textDocument/documentColor", params, function(err, result, _, _)
    if err then return vim.notify(err.message, vim.log.levels.ERROR) end
    if not vim.api.nvim_buf_is_valid(bufnr) then return end

    ---@type lsp.ColorInformation[]
    local colors = result
    vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)

    for _, color in pairs(colors) do
      local r = math.floor(color.color.red * 255)
      local g = math.floor(color.color.green * 255)
      local b = math.floor(color.color.blue * 255)
      local hl_group = utils.set_hl_from(r, g, b)
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- starts at 1

      if
          not conceal.is_enabled or (conceal.is_enabled and cursor_line == color.range.start.line)
      then
        pcall(function() set_extmark(bufnr, color.range, hl_group) end)
      end
    end
  end, bufnr)
end

---@param bufnr number
---@param client vim.lsp.Client
local debounced_request = function(bufnr, client)
  local timer = M.request_timer

  if timer then
    M.request_timer = nil
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end

  M.request_timer = vim.defer_fn(function() color_request(bufnr, client) end, 200)
end

---@private
M.request_timer = nil

M.on_attach = function(args)
  local bufnr = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)

  if client and client.name == "tailwindcss" then
    vim.api.nvim_create_autocmd(color_events, {
      group = vim.g.tailwind_tools.color_au,
      callback = function(a)
        if a.event == "TextChangedI" then
          debounced_request(bufnr, client)
          -- in the case of a cursor event requests are sent only if conceal is enabled
        elseif vim.startswith(a.event, "Cursor") == conceal.is_enabled then
          color_request(bufnr, client)
        end
      end,
    })
    color_request(bufnr, client)
  end
end

return M
