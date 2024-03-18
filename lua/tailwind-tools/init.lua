local M = {}

local lsp = require("tailwind-tools.lsp")
local config = require("tailwind-tools.config")
local conceal = require("tailwind-tools.conceal")

---@param options TailwindTools.Option
M.setup = function(options)
  config.options = vim.tbl_deep_extend("keep", options, config.options)

  vim.g.tailwind_tools = {
    color_ns = vim.api.nvim_create_namespace("tailwind_colors"),
    color_au = vim.api.nvim_create_augroup("tailwind_colors", {}),
    conceal_ns = vim.api.nvim_create_namespace("tailwind_conceal"),
    conceal_au = vim.api.nvim_create_augroup("tailwind_conceal", {}),
  }

  vim.api.nvim_set_hl(0, "TailwindConceal", config.options.conceal.highlight)
  vim.api.nvim_create_user_command("TailwindConcealEnable", conceal.enable, { nargs = 0 })
  vim.api.nvim_create_user_command("TailwindConcealDisable", conceal.disable, { nargs = 0 })
  vim.api.nvim_create_user_command("TailwindConcealToggle", conceal.toggle, { nargs = 0 })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.g.tailwind_tools.conceal_au,
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client and client.name == "tailwindcss" then
        vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
          group = vim.g.tailwind_tools.conceal_au,
          buffer = bufnr,
          callback = function() lsp.color_request(bufnr, client) end,
        })
        lsp.color_request(bufnr, client)
      end
    end,
  })
end

return M
