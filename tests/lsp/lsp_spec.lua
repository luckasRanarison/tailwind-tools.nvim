local assert = require("luassert")
local utils = require("tailwind-tools.utils")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local get_extmarks = require("tests.common").get_extmarks

local files = {
  v3 = "tests/lsp/v3/index.html",
  -- v4 = "tests/lsp/v4/index.html",
}

for version, file in pairs(files) do
  -- FIXME: tailwind-language-server can't handle two projects at the same time
  vim.cmd.LspRestart()

  describe(("project (%s):"):format(version), function()
    it("Should initialize project", function()
      vim.cmd.edit(file)

      ---@type vim.lsp.Client | nil
      local client

      vim.wait(10000, function()
        client = vim.lsp.get_clients({ bufnr = 0, name = "tailwindcss" })[1]
        return client ~= nil
      end)

      assert(client, "Couldn't get client")

      local bufnr = vim.api.nvim_get_current_buf()
      local params = vim.lsp.util.make_text_document_params(bufnr)
      local response

      vim.wait(10000, function()
        response = client.request_sync("@/tailwindCSS/getProject", params, 5000, bufnr)
        return response and response.result
      end)

      assert(response, "No response from the server")
      assert(response.result, "No project found")
    end)
  end)

  describe(("color (%s):"):format(version), function()
    local ns = vim.g.tailwind_tools.color_ns

    it("Should show inline colors", function()
      config.options.document_color.kind = "inline"

      vim.wait(5000, function() return #state.color.active_buffers ~= 0 end)

      local symbol = config.options.document_color.inline_symbol
      local extmarks = get_extmarks(0, ns, { "virt_text" })

      local expected = {
        { 12, 64, { virt_text = { { symbol, "TailwindColorFg111827" } } } },
        { 14, 40, { virt_text = { { symbol, "TailwindColorFg22d3ee" } } } },
      }

      assert.same(expected, extmarks)
    end)

    it("Should clear colors", function()
      vim.cmd.TailwindColorDisable()

      assert.same({}, get_extmarks(0, ns))
      assert.same({}, state.color.active_buffers)
    end)

    it("Should show background colors", function()
      config.options.document_color.kind = "background"

      vim.cmd.TailwindColorEnable()
      vim.wait(5000, function() return #state.color.active_buffers ~= 0 end)

      local extmarks = get_extmarks(0, ns, { "hl_group" })

      local expected = {
        { 12, 64, 12, 76, { hl_group = "TailwindColorBg111827" } },
        { 14, 40, 14, 54, { hl_group = "TailwindColorBg22d3ee" } },
      }

      assert.same(expected, extmarks)

      vim.cmd.TailwindColorDisable()
    end)

    it("Should show foreground colors", function()
      config.options.document_color.kind = "foreground"

      vim.cmd.TailwindColorEnable()
      vim.wait(5000, function() return #state.color.active_buffers ~= 0 end)

      local extmarks = get_extmarks(0, ns, { "hl_group" })

      local expected = {
        { 12, 64, 12, 76, { hl_group = "TailwindColorFg111827" } },
        { 14, 40, 14, 54, { hl_group = "TailwindColorFg22d3ee" } },
      }

      assert.same(expected, extmarks)
    end)

    it("Should not be affected by colorscheme", function()
      vim.cmd.colorscheme("vim")

      local extmarks = get_extmarks(0, ns, { "hl_group" })

      local expected = {
        { 12, 64, 12, 76, { hl_group = "TailwindColorFg111827" } },
        { 14, 40, 14, 54, { hl_group = "TailwindColorFg22d3ee" } },
      }

      assert.same(expected, extmarks)
    end)
  end)

  describe(("sort (%s):"):format(version), function()
    it("Should sort selection", function()
      vim.cmd.TailwindNextClass()
      vim.cmd.normal('vi"\28\14')
      vim.cmd([['<,'>TailwindSortSelectionSync]])

      local s_row, s_col, e_row, e_col = utils.get_visual_range()
      local class = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col, {})
      local expected = "flex h-screen w-screen items-center justify-center bg-[#111827]"

      assert.same(expected, class[1])
    end)

    it("Should sort all classes", function()
      vim.cmd.normal("u")
      vim.cmd.TailwindSortSync()

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

      vim.cmd.edit("tests/lsp/sorted.html")

      local expected = vim.api.nvim_buf_get_lines(0, 0, -1, true)

      assert.same(expected, lines)
    end)
  end)
end
