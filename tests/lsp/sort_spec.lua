local assert = require("luassert")

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
    vim.cmd([['<,'>TailwindSortSelection]])
    vim.wait(2000, function() return vim.bo.modified end)

    local start_col = vim.fn.col("'<") - 1
    local end_col = vim.fn.col("'>")
    local start_row = vim.fn.line("'<") - 1
    local end_row = vim.fn.line("'>") - 1
    local class = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})

    local expected = "flex h-screen w-screen items-center justify-center bg-[#111827]"

    assert.same(expected, class[1])
  end)

  it("Should sort all classes", function()
    vim.cmd.normal("u")
    vim.cmd.TailwindSort()
    vim.wait(2000, function() return vim.bo.modified end)

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

    vim.cmd.edit("tests/lsp/sorted.html")

    local expected = vim.api.nvim_buf_get_lines(0, 0, -1, true)

    assert.same(expected, lines)
  end)
end)
