local common = require("tests.queries.common")
local runner = common.Runner:new("tests/queries/twig/test.twig")

describe("queries twig:", function()
  runner:classes(3)
  runner:ranges({
    { 0, 12, 0, 26 },
    { 1, 14, 1, 41 },
    { 4, 17, 4, 27 },
  })
end)
