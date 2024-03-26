local common = require("tests.queries.common")
local runner = common.Runner:new("tests/queries/tsx/Component.tsx")

describe("queries tsx:", function()
  runner:classes(3)
  runner:ranges({
    { 6, 19, 7, 55 },
    { 9, 24, 9, 47 },
    { 13, 33, 13, 45 },
  })
end)
