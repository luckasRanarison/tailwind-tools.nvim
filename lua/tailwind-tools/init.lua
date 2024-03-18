local M = {}

local config = require("tailwind-tools.config")
local fold = require("tailwind-tools.fold")

---@param options TailwindTools.Option
M.setup = function(options)
  config.setup(options)

  vim.g.tailwind_tools = {
    conceal_ns = vim.api.nvim_create_namespace("tailwind_conceal"),
    conceal_au = vim.api.nvim_create_augroup("tailwind_conceal", {}),
  }

  vim.api.nvim_set_hl(0, "TailwindConceal", config.options.conceal.highlight)
  vim.api.nvim_create_user_command("TailwindFoldEnable", fold.enable, { nargs = 0 })
  vim.api.nvim_create_user_command("TailwindFoldDisable", fold.disable, { nargs = 0 })
  vim.api.nvim_create_user_command("TailwindFoldToggle", fold.toggle, { nargs = 0 })
end

return M
