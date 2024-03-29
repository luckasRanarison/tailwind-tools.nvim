local M = {}

local log = require("tailwind-tools.log")
local utils = require("tailwind-tools.utils")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
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
  ---@diagnostic disable-next-line: deprecated
  local get_client = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_client({ name = "tailwindcss" })
  return clients[1]
end

---@param bufnr number
---@param color lsp.ColorInformation
local function set_extmark(bufnr, color)
  local r = math.floor(color.color.red * 255)
  local g = math.floor(color.color.green * 255)
  local b = math.floor(color.color.blue * 255)
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
  table.insert(state.color.active_buffers, bufnr)
end

---@param bufnr number
local function debounced_color_request(bufnr)
  local timer = state.color.request_timer

  if timer then
    state.color.request_timer = nil
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end

  state.color.request_timer = vim.defer_fn(
    function() M.color_request(bufnr) end,
    config.options.document_color.debounce
  )
end

M.on_attach = function(args)
  local bufnr = args.buf
  local client = get_tailwindcss()

  if not client then return end

  vim.api.nvim_create_autocmd(color_events, {
    group = vim.g.tailwind_tools.color_au,
    buffer = bufnr,
    callback = function(a)
      if not state.color.enabled then return end
      if a.event == "TextChangedI" then
        debounced_color_request(bufnr)
      elseif vim.startswith(a.event, "Cursor") == state.conceal.enabled then
        M.color_request(bufnr)
      end
    end,
  })

  M.color_request(bufnr)
end

---@param bufnr number
M.color_request = function(bufnr)
  local client = get_tailwindcss()
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  if not client then return end

  client.request("textDocument/documentColor", params, function(err, result, _, _)
    if err then return log.error(err.message) end
    if not result or not vim.api.nvim_buf_is_valid(bufnr) then return end

    ---@type lsp.ColorInformation[]
    local colors = result
    vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)

    for _, color in pairs(colors) do
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Starts at 1
      local cursor_aligned = (state.conceal.enabled and cursor_line == color.range.start.line)

      if not state.conceal.enabled or cursor_aligned then
        pcall(function() set_extmark(bufnr, color) end)
      end
    end
  end, bufnr)
end

M.enable_color = function()
  local client = get_tailwindcss()
  if client then
    M.color_request(0)
    state.color.enabled = true
  end
end

M.disable_color = function()
  for _, bufnr in pairs(state.color.active_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)
    end
  end

  state.color.active_buffers = {}
  state.color.enabled = false
end

M.toggle_colors = function()
  if state.color.enabled then
    M.disable_color()
  else
    M.enable_color()
  end
end

M.sort_selection = function()
  local client = get_tailwindcss()

  if not client then return log.warn("tailwind-language-server is not running") end

  local bufnr = vim.api.nvim_get_current_buf()
  local start_col = vim.fn.col("'<") - 1
  local end_col = vim.fn.col("'>")
  local start_row = vim.fn.line("'<") - 1
  local end_row = vim.fn.line("'>") - 1
  local class = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

  if class then
    local params = vim.lsp.util.make_text_document_params(bufnr)

    params.classLists = { table.concat(class, "\n") }
    client.request("@/tailwindCSS/sortSelection", params, function(err, result, _, _)
      if err then return log.error(err.message) end
      if result.error then return log.error(result.error) end
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      local formatted = vim.split(result.classLists[1], "\n")

      vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, formatted)
    end, bufnr)
  end
end

M.sort_classes = function()
  local client = get_tailwindcss()

  if not client then return log.warn("tailwind-language-server is not running") end

  local bufnr = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_text_document_params(bufnr)
  local class_nodes = treesitter.get_class_nodes(bufnr)

  if not class_nodes then return end

  local class_text = {}
  local class_ranges = {}

  for _, node in pairs(class_nodes) do
    local start_row, start_col, end_row, end_col = treesitter.get_class_range(node, bufnr)
    local text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    class_text[#class_text + 1] = table.concat(text, "\n")
    class_ranges[#class_ranges + 1] = { start_row, start_col, end_row, end_col }
  end

  params.classLists = class_text
  client.request("@/tailwindCSS/sortSelection", params, function(err, result, _, _)
    if err then return log.error(err.message) end
    if result.error then return log.error(result.error) end
    if not result or not vim.api.nvim_buf_is_valid(bufnr) then return end

    for i, edit in pairs(result.classLists) do
      local lines = vim.split(edit, "\n")
      local start_row, start_col, end_row, end_col = unpack(class_ranges[i])
      local set_text = function()
        vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, lines)
      end
      -- Dismiss useless error messages when undoing in nightly
      pcall(set_text)
    end
  end, bufnr)
end

return M
