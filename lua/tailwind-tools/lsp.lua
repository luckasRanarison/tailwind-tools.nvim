local M = {}

local log = require("tailwind-tools.log")
local utils = require("tailwind-tools.utils")
local config = require("tailwind-tools.config")
local conceal = require("tailwind-tools.conceal")
local treesitter = require("tailwind-tools.treesitter")

local color_events = {
  "BufEnter",
  "TextChanged",
  "TextChangedI",
  "CursorMoved",
  "CursorMovedI",
}

---@return vim.lsp.Client?
local function get_tailwindcss()
  local get_client = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_client({ name = "tailwindcss" })
  return clients[1]
end

---@param bufnr number
---@param color lsp.ColorInformation
local function set_extmark(bufnr, color)
  local r, g, b = utils.lsp_color_to_rgb(color.color)
  local hl_kind = config.options.document_color.kind
  local hl_group = utils.set_hl_from(r, g, b, hl_kind)
  local namespace = vim.g.tailwind_tools.color_ns
  local start_row = color.range.start.line
  local start_col = color.range.start.character
  local opts = nil

  if hl_kind == "inline" then
    opts = {
      virt_text = {
        { config.options.document_color.inline_symbol, hl_group },
      },
      virt_text_pos = "inline",
    }
  else
    opts = {
      hl_group = hl_group,
      end_row = color.range["end"].line,
      end_col = color.range["end"].character,
      priority = 1000,
    }
  end

  vim.api.nvim_buf_set_extmark(bufnr, namespace, start_row, start_col, opts)
end

---@param bufnr number
---@param client vim.lsp.Client
local function color_request(bufnr, client)
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  client.request("textDocument/documentColor", params, function(err, result, _, _)
    if err then return log.error(err.message) end
    if not vim.api.nvim_buf_is_valid(bufnr) then return end

    ---@type lsp.ColorInformation[]
    local colors = result
    vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)

    for _, color in pairs(colors) do
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- starts at 1
      local cursor_aligned = (conceal.is_enabled and cursor_line == color.range.start.line)

      if not conceal.is_enabled or cursor_aligned then
        pcall(function() set_extmark(bufnr, color) end)
      end
    end
  end, bufnr)
end

---@param bufnr number
---@param client vim.lsp.Client
local function debounced_color_request(bufnr, client)
  local timer = M.request_timer

  if timer then
    M.request_timer = nil
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end

  M.request_timer = vim.defer_fn(
    function() color_request(bufnr, client) end,
    config.options.document_color.debounce
  )
end

---@private
M.request_timer = nil

M.on_attach = function(args)
  local bufnr = args.buf
  local client = get_tailwindcss()

  if client then
    vim.api.nvim_create_autocmd(color_events, {
      group = vim.g.tailwind_tools.color_au,
      callback = function(a)
        if a.event == "TextChangedI" then
          debounced_color_request(bufnr, client)
          -- In the case of a cursor event, requests are sent only if conceal is enabled
        elseif vim.startswith(a.event, "Cursor") == conceal.is_enabled then
          color_request(bufnr, client)
        end
      end,
    })
    color_request(bufnr, client)
  end
end

M.sort_selection = function()
  local client = get_tailwindcss()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_col = vim.fn.col("'<") - 1
  local end_col = vim.fn.col("'>")
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local class = vim.api.nvim_buf_get_text(bufnr, row, start_col, row, end_col, {})[1]

  if client and class then
    local params = vim.lsp.util.make_text_document_params(bufnr)

    params.classLists = { class }
    client.request("@/tailwindCSS/sortSelection", params, function(err, result, _, _)
      if err then return log.error(err.message) end
      vim.api.nvim_buf_set_text(bufnr, row, start_col, row, end_col, result.classLists)
    end, bufnr)
  end
end

M.sort_classes = function()
  local client = get_tailwindcss()

  if not client then return end

  local bufnr = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_text_document_params(bufnr)
  local class_nodes = treesitter.get_class_iter(bufnr)
  local class_text = {}
  local class_ranges = {}

  for _, match in class_nodes do
    local node = match[2][1] or match[2]
    local start_row, start_col, end_row, end_col = treesitter.get_node_range(node, bufnr)
    local text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})[1]

    if start_row == end_row then
      class_text[#class_text + 1] = text
      class_ranges[#class_ranges + 1] = { start_row, start_col, end_col }
    end
  end

  params.classLists = class_text
  client.request("@/tailwindCSS/sortSelection", params, function(err, result, _, _)
    if err then return log.error(err.message) end

    for i, edit in pairs(result.classLists) do
      local row, start_col, end_col = unpack(class_ranges[i])
      vim.api.nvim_buf_set_text(bufnr, row, start_col, row, end_col, { edit })
    end
  end, bufnr)
end

return M
