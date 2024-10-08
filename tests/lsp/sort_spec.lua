local assert = require("luassert")
local utils = require("tailwind-tools.utils")

describe("sort:", function()
  it("Should initialize project", function()
    vim.cmd.edit("tests/lsp/project/index.html")

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
      response = client.request_sync("@/tailwindCSS/getProject", params, 2000, bufnr)
      return response and response.result
    end)

    assert(response, "No response from the server")
    assert(response.result, "No project found")
  end)

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
