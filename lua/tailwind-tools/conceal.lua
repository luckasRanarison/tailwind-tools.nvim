local M = {}

local lsp = require("tailwind-tools.lsp")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local treesitter = require("tailwind-tools.treesitter")

---@param bufnr number
local function set_conceal(bufnr)
  local class_nodes = treesitter.get_class_iter(bufnr)

  if not class_nodes then return end

  vim.wo.conceallevel = 2
  vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.conceal_ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)
  table.insert(state.conceal.active_buffers, bufnr)

  for _, match in class_nodes do
    local node = match[2][1] or match[2]
    local start_row, start_col, end_row, end_col = treesitter.get_class_range(node, bufnr)

    vim.api.nvim_buf_set_extmark(bufnr, vim.g.tailwind_tools.conceal_ns, start_row, start_col, {
      end_line = end_row,
      end_col = end_col,
      conceal = config.options.conceal.symbol,
      hl_group = "TailwindConceal",
      priority = 0, -- To ignore conceal hl_group when focused
    })
  end
end

M.enable = function()
  for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then set_conceal(bufnr) end
  end

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

  state.conceal.enabled = true
  if state.color.enabled then lsp.color_request(0) end
end

M.disable = function()
  vim.wo.conceallevel = 0
  vim.api.nvim_clear_autocmds({
    group = vim.g.tailwind_tools.conceal_au,
    event = { "TextChanged", "TextChangedI" },
  })

  for _, bufnr in pairs(state.conceal.active_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.conceal_ns, 0, -1)
    end
  end

  state.conceal.active_buffers = {}
  state.conceal.enabled = false
  if state.color.enabled then lsp.color_request(0) end
end

M.toggle = function()
  if state.conceal.enabled then
    M.disable()
  else
    M.enable()
  end
end

return M
