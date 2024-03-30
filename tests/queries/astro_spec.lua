local common = require("tests.queries.common")
local runner = common.Runner:new("tests/queries/astro/index.astro")

describe("queries astro:", function()
  runner:classes(3)
  runner:ranges({
    { 4, 12, 4, 26 },
    { 5, 14, 5, 41 },
    { 7, 33, 7, 43 },
  })
end)
