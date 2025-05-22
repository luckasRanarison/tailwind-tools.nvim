local assert = require("luassert")
local utils = require("tests.common")

-- NOTE: keymaps don't work in headless mode, so we use user commands instead for simulation

local function increment()
  vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
  vim.cmd.TailwindIncrement()
end

local function decrement()
  vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
  vim.cmd.TailwindDecrement()
end

local function assert_line(pattern)
  local cursosr = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(0, cursosr[1] - 1, cursosr[1], true)[1]
  local start = line:find(pattern, 1, true)

  assert(start ~= nil, string.format("line: %s, pattern: %s", line, pattern))
end

describe("smart increment:", function()
  vim.cmd.edit("tests/keymaps/index.html")

  it("should increment scale units", function()
    vim.cmd.TailwindNextClass()
    -- font-bold text-md
    -- ^              ^ Target

    increment()
    assert_line("text-lg")

    increment()
    assert_line("text-xl")

    increment()
    assert_line("text-2xl")

    for _ = 1, 10, 1 do
      increment()
    end

    assert_line("text-9xl")

    utils.assert_cursor(11, 31)
  end)

  it("should decrement scale units", function()
    vim.cmd.normal("e")
    utils.assert_cursor(11, 33)
    -- font-bold text-9xl
    --                  ^

    for _ = 1, 8 do
      decrement()
    end

    assert_line("text-xl")
    utils.assert_cursor(11, 32)
    -- font-bold text-xl
    --                 ^

    decrement()
    assert_line("text-lg")

    decrement()
    assert_line("text-md")

    decrement()
    assert_line("text-sm")

    for _ = 1, 3 do
      decrement()
    end

    assert_line("text-xs")
  end)

  it("should handle size units", function()
    vim.cmd.TailwindNextClass()
    -- container mx-auto p-11 bg-gray-100
    -- ^                   ^ Target

    increment()
    assert_line("p-12")

    increment()
    assert_line("p-14")

    decrement()
    assert_line("p-12")

    decrement()
    assert_line("p-11")
  end)

  it("should handle palette units", function()
    vim.cmd.normal("W")
    -- container mx-auto p-11 bg-gray-100
    --                     ^          ^ Target

    decrement()
    assert_line("bg-gray-50")

    for i = 1, 5 do
      increment()
      assert_line("bg-gray-" .. i .. "00")
    end
  end)

  it("should handle border units", function()
    vim.cmd.TailwindNextClass()
    vim.cmd.normal("3W")
    -- text-2xl font-bold mb-4 border-2 border-md
    -- ^                              ^ Target

    increment()
    assert_line("border-4")

    increment()
    assert_line("border-6")

    for _ = 1, 4 do
      increment()
    end

    assert_line("border-8")
  end)
end)
