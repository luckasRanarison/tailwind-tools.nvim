local utils = require("tests.common")

describe("jump motion:", function()
  vim.cmd.edit("tests/motions/index.html")

  it("should go to the next class", function()
    vim.cmd.TailwindNextClass()
    utils.assert_cursor(11, 14)

    vim.cmd.TailwindNextClass()
    utils.assert_cursor(12, 14)

    vim.cmd.TailwindNextClass()
    utils.assert_cursor(13, 16)

    vim.cmd.TailwindNextClass()
    utils.assert_cursor(13, 16)
  end)

  it("should go to the prev class", function()
    vim.cmd.TailwindPrevClass()
    utils.assert_cursor(12, 14)

    vim.cmd.TailwindPrevClass()
    utils.assert_cursor(11, 14)

    vim.cmd.TailwindPrevClass()
    utils.assert_cursor(11, 14)
  end)

  it("should go to the last class", function()
    vim.cmd.normal("3")
    vim.cmd.TailwindNextClass()
    utils.assert_cursor(13, 16)
  end)
end)
