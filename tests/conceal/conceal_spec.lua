local assert = require("luassert")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local get_extmarks = require("tests.common").get_extmarks

local ns = vim.g.tailwind_tools.conceal_ns

describe("conceal:", function()
  it("Should conceal all classes", function()
    vim.cmd.edit("tests/queries/html/index.html")
    vim.cmd.TailwindConcealEnable()

    local expected = {
      { 10, 14, 10, 47 },
      { 11, 16, 11, 39 },
    }

    assert.same(expected, get_extmarks(0, ns))
  end)

  it("Should conceal on BufEnter", function()
    vim.cmd.edit("tests/queries/css/style.css")

    local expected = {
      { 5, 9, 5, 34 },
      { 9, 9, 10, 37 },
    }

    assert.same(expected, get_extmarks(0, ns))
  end)

  it("Should clear conceals in all buffers", function()
    local buffers = state.conceal.active_buffers

    assert.same(2, #buffers)

    vim.cmd.TailwindConcealDisable()

    for bufnr, _ in pairs(buffers) do
      assert(vim.api.nvim_buf_is_valid(bufnr))
      assert({}, get_extmarks(bufnr, ns))
    end
  end)

  it("Should only conceal long classes", function()
    config.options.conceal.min_length = 40

    vim.cmd.edit("tests/conceal/Component.jsx")
    vim.cmd.TailwindConcealEnable()

    local expected = {
      { 6, 20, 6, 80 },
      { 9, 19, 10, 41 },
    }

    assert.same(expected, get_extmarks(0, ns))

    vim.cmd.TailwindConcealDisable()

    assert.same({}, get_extmarks(0, ns))
  end)
end)
