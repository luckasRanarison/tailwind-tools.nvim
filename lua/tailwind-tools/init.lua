local M = {}

local config = require("tailwind-tools.config")
local fold = require("tailwind-tools.fold")

M.enable_fold = function()
  vim.opt_local.conceallevel = 2
  fold.set_conceal(0)
  fold.attach_autocmd()
end

M.disable_fold = function()
  vim.opt_local.conceallevel = 0
  vim.api.nvim_clear_autocmds({ group = vim.g.tailwind_tools.augroup })
  vim.api.nvim_buf_clear_namespace(0, vim.g.tailwind_tools.namespace, 0, -1)
end

M.is_fold_enabled = function()
  return #vim.api.nvim_get_autocmds({ group = vim.g.tailwind_tools.augroup }) > 0
end

M.toggle_fold = function()
  if M.is_fold_enabled() then
    M.disable_fold()
  else
    M.enable_fold()
  end
end

---@param options TailwindTools.Option
M.setup = function(options)
  config.setup(options)

  vim.g.tailwind_tools = {
    namespace = vim.api.nvim_create_namespace("tailwind_tools"),
    augroup = vim.api.nvim_create_augroup("tailwind_conceal", {}),
  }

  vim.api.nvim_set_hl(0, "TailwindConceal", config.options.conceal.highlight)
  vim.api.nvim_create_user_command("TailwindFoldEnable", M.enable_fold, { nargs = 0 })
  vim.api.nvim_create_user_command("TailwindFoldDisable", M.disable_fold, { nargs = 0 })
  vim.api.nvim_create_user_command("TailwindFoldToggle", M.toggle_fold, { nargs = 0 })
end

return M
