local M = {}

local lsp = require("tailwind-tools.lsp")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local classes = require("tailwind-tools.classes")

---@param bufnr number
local function set_conceal(bufnr)
  local class_ranges = classes.get_ranges(bufnr)

  if #class_ranges == 0 then return end

  vim.wo.conceallevel = 2
  vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.conceal_ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)
  state.conceal.active_buffers[bufnr] = true

  local opts = config.options.conceal

  for _, range in pairs(class_ranges) do
    local start_row, start_col, end_row, end_col = unpack(range)

    if not opts.min_length or end_row ~= start_row or end_col - start_col >= opts.min_length then
      vim.api.nvim_buf_set_extmark(bufnr, vim.g.tailwind_tools.conceal_ns, start_row, start_col, {
        end_line = end_row,
        end_col = end_col,
        conceal = opts.symbol,
        hl_group = "TailwindConceal",
        priority = 0, -- To ignore conceal hl_group when focused
      })
    end
  end
end

M.enable = function()
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = vim.g.tailwind_tools.conceal_au,
    callback = function(args) set_conceal(args.buf) end,
  })
  -- Workaround to reset conceallevel per buffer
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.g.tailwind_tools.conceal_au,
    callback = function(args)
      vim.wo.conceallevel = vim.opt.conceallevel:get()
      if state.conceal.enabled then set_conceal(args.buf) end
    end,
  })

  for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then set_conceal(bufnr) end
  end

  -- Restore color hints
  if state.color.enabled then lsp.color_request(0) end

  state.conceal.enabled = true
end

M.disable = function()
  vim.wo.conceallevel = 0
  vim.api.nvim_clear_autocmds({
    group = vim.g.tailwind_tools.conceal_au,
    event = { "TextChanged", "TextChangedI" },
  })

  for bufnr, _ in pairs(state.conceal.active_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.conceal_ns, 0, -1)
    end
  end

  if state.color.enabled then lsp.color_request(0) end

  state.conceal.active_buffers = {}
  state.conceal.enabled = false
end

M.toggle = function()
  if state.conceal.enabled then
    M.disable()
  else
    M.enable()
  end
end

return M
