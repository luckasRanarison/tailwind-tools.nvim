local M = {}

local config = require("tailwind-tools.config")
local treesitter = require("tailwind-tools.treesitter")

---@param bufnr number
local function set_conceal(bufnr)
  local class_nodes = treesitter.get_class_iter(bufnr)

  if not class_nodes then return end

  vim.wo.conceallevel = 2
  vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.conceal_ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)

  for _, match in class_nodes do
    local node = match[2][1] or match[2]
    local start_row, start_col, end_row, end_col = treesitter.get_node_range(node, bufnr)

    vim.api.nvim_buf_set_extmark(bufnr, vim.g.tailwind_tools.conceal_ns, start_row, start_col, {
      end_line = end_row,
      end_col = end_col,
      conceal = config.options.conceal.symbol,
      hl_group = "TailwindConceal",
      priority = 0, -- to ignore conceal hl_group when focused
    })
  end
end

M.is_enabled = false

M.enable = function()
  M.is_enabled = true

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = vim.g.tailwind_tools.conceal_au,
    callback = function(args) set_conceal(args.buf) end,
  })
  -- Workaround to reset conceallevel and clear other buffers extmarks
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.g.tailwind_tools.conceal_au,
    callback = function(args)
      if M.is_enabled then
        set_conceal(args.buf)
      else
        vim.wo.conceallevel = vim.opt.conceallevel:get()
        vim.api.nvim_buf_clear_namespace(0, vim.g.tailwind_tools.conceal_ns, 0, -1)
      end
    end,
  })
  set_conceal(0)
end

M.disable = function()
  M.is_enabled = false

  vim.wo.conceallevel = 0
  vim.api.nvim_clear_autocmds({
    group = vim.g.tailwind_tools.conceal_au,
    event = { "TextChanged", "TextChangedI" },
  })
  vim.api.nvim_buf_clear_namespace(0, vim.g.tailwind_tools.conceal_ns, 0, -1)
  vim.cmd("doautocmd TextChanged") -- A hack for recovering the color highlights
end

M.toggle = function()
  if M.is_enabled then
    M.disable()
  else
    M.enable()
  end
end

return M
