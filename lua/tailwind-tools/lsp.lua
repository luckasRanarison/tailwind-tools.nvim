local M = {}

local log = require("tailwind-tools.log")
local utils = require("tailwind-tools.utils")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local classes = require("tailwind-tools.classes")
local filetypes = require("tailwind-tools.filetypes")

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
  local opts = {}

  if hl_kind == "inline" then
    opts.virt_text = { { config.options.document_color.inline_symbol, hl_group } }
    opts.virt_text_pos = "inline"
  else
    opts.hl_group = hl_group
    opts.end_row = color.range["end"].line
    opts.end_col = color.range["end"].character
    opts.priority = 1000
  end

  vim.api.nvim_buf_set_extmark(bufnr, namespace, start_row, start_col, opts)
  state.color.active_buffers[bufnr] = true
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

---@param ranges number[][]
---@param bufnr number
---@param sync boolean
local function sort_classes(ranges, bufnr, sync)
  local client = get_tailwindcss()

  if not client then return log.error("tailwind-language-server is not running") end
  if #ranges == 0 then return end

  local class_text = {}

  for _, range in pairs(ranges) do
    local start_row, start_col, end_row, end_col = unpack(range)
    local text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    class_text[#class_text + 1] = table.concat(text, "\n")
  end

  local params = vim.tbl_extend("error", vim.lsp.util.make_text_document_params(bufnr), {
    classLists = class_text,
  })

  local handler = function(err, result, _, _)
    if err then return log.error(err.message) end
    if result.error then return log.error(result.error) end
    if not result or not vim.api.nvim_buf_is_valid(bufnr) then return end

    for i, edit in pairs(result.classLists) do
      local lines = vim.split(edit, "\n")
      local s_row, s_col, e_row, e_col = unpack(ranges[i])

      -- Dismiss useless error messages when undoing in nightly
      pcall(function() vim.api.nvim_buf_set_text(bufnr, s_row, s_col, e_row, e_col, lines) end)
    end
  end

  if sync then
    local response = client.request_sync("@/tailwindCSS/sortSelection", params, 2000, bufnr)

    if response then
      handler(response.err, response.result)
    else
      log.error("LSP request timed out")
    end
  else
    client.request("@/tailwindCSS/sortSelection", params, handler, bufnr)
  end
end

---@param opts TailwindTools.ServerOption
M.setup = function(opts, lspconfig)
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  capabilities.textDocument.colorProvider = {
    dynamicRegistration = true,
  }

  lspconfig.tailwindcss.setup({
    capabilities = capabilities,
    on_attach = opts.on_attach,
    filetypes = filetypes.get_all(),
    init_options = {
      userLanguages = filetypes.get_server_map(),
    },
    settings = {
      tailwindCSS = opts.settings,
      includeLanguages = filetypes.get_server_map(),
    },
    root_dir = lspconfig.util.root_pattern(
      "tailwind.config.{js,cjs,mjs,ts}",
      "assets/tailwind.config.{js,cjs,mjs,ts}"
    ),
  })
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

  if state.color.enabled then M.color_request(bufnr) end
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
  for bufnr, _ in pairs(state.color.active_buffers) do
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

---@param sync boolean
M.sort_selection = function(sync)
  local bufnr = vim.api.nvim_get_current_buf()
  local s_row, s_col, e_row, e_col = utils.get_visual_range()
  local class_ranges = { { s_row, s_col, e_row, e_col } }

  sort_classes(class_ranges, bufnr, sync)
end

---@param sync boolean
M.sort_classes = function(sync)
  local bufnr = vim.api.nvim_get_current_buf()
  local class_ranges = classes.get_ranges(bufnr, { sortable = true })

  sort_classes(class_ranges, bufnr, sync)
end

return M
