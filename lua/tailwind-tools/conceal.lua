local M = {}

local config = require("tailwind-tools.config")

local lang_map = {
  html = { "html", "php" },
  tsx = {
    "astro",
    "vue",
    "svete",
    "javascriptreact",
    "typescriptreact",
  },
}

local query_map = {
  html = [[
    (attribute
      (attribute_name) @_attribute_name
      (#eq? @_attribute_name "class")
      (quoted_attribute_value
        (attribute_value) @_attribute_value))
  ]],
  tsx = [[
    (jsx_attribute
    (property_identifier) @_attribute_name
    (#eq? @_attribute_name "className")
    [
      (string
        (string_fragment) @_attribute_value)
      (jsx_expression
        (_) @_attribute_value)
    ])
  ]],
}

---@param bufnr number
local set_conceal = function(bufnr)
  local lang = nil

  for key, filetypes in pairs(lang_map) do
    if vim.tbl_contains(filetypes, vim.bo.ft) then lang = key end
  end

  if not lang then return end

  local parser = vim.treesitter.get_parser(bufnr, lang)
  local tree = parser:parse()
  local root = tree[1]:root()
  local query = vim.treesitter.query.parse(lang, query_map[lang])
  local iter = query:iter_matches(root, bufnr, root:start(), root:end_(), { all = true })

  vim.wo.conceallevel = 2
  vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.conceal_ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, vim.g.tailwind_tools.color_ns, 0, -1)

  for _, match in iter do
    local target = match[2][1] or match[2]
    local start_row, start_col, end_row, end_col = target:range()

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
end

M.toggle = function()
  if M.is_enabled then
    M.disable()
  else
    M.enable()
  end
end

return M
