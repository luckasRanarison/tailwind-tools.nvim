local common = require("tests.queries.common")
local runner = common.Runner:new("tests/queries/svelte/test.svelte")

describe("queries svelte:", function()
  runner:classes(3)
  runner:ranges({
    { 4, 12, 4, 26 },
    { 5, 14, 5, 41 },
    { 8, 17, 8, 27 },
  })
end)
