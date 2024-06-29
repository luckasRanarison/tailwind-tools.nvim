local common = require("tests.queries.common")
local runner = common.Runner:new("tests/queries/astro/index.astro")

describe("queries astro:", function()
  runner:classes(4)
  runner:ranges({
    { 4, 17, 4, 42 },
    { 6, 12, 6, 26 },
    { 7, 14, 7, 41 },
    { 9, 33, 9, 43 },
  })
end)
