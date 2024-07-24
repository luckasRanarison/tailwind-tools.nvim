local common = require("tests.queries.common")
local runner = common.Runner:new("tests/queries/heex/index.html.heex")

describe("queries heex:", function()
  runner:classes(3)
  runner:ranges({
    { 0, 12, 0, 27 },
    { 1, 13, 1, 20 },
    { 2, 12, 5, 4 },
  })
end)
