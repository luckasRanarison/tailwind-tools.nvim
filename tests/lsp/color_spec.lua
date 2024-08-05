local assert = require("luassert")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local get_extmarks = require("tests.common").get_extmarks

local ns = vim.g.tailwind_tools.color_ns

describe("color:", function()
  it("Should attach to the buffer", function()
    vim.cmd.edit("tests/lsp/project/index.html")

    local client

    vim.wait(10000, function()
      client = vim.lsp.get_clients({ bufnr = 0, name = "tailwindcss" })[1]
      return client ~= nil
    end)

    assert(client)
  end)

  it("Should show inline colors", function()
    vim.wait(10000, function() return #state.color.active_buffers ~= 0 end)

    local symbol = config.options.document_color.inline_symbol
    local extmarks = get_extmarks(0, ns, { "virt_text" })

    local expected = {
      { 12, 65, { virt_text = { { symbol, "TailwindColorFg111827" } } } },
      { 13, 38, { virt_text = { { symbol, "TailwindColorFg22d3ee" } } } },
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
      { 12, 65, 12, 77, { hl_group = "TailwindColorBg111827" } },
      { 13, 38, 13, 52, { hl_group = "TailwindColorBg22d3ee" } },
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
      { 12, 65, 12, 77, { hl_group = "TailwindColorFg111827" } },
      { 13, 38, 13, 52, { hl_group = "TailwindColorFg22d3ee" } },
    }

    assert.same(expected, extmarks)
  end)
end)
