local common = require("tests.queries.common")
local runner = common.Runner:new("tests/queries/vue/test.vue")

describe("queries vue:", function()
  runner:classes(3)
  runner:ranges({
    { 1, 14, 1, 28 },
    { 2, 16, 2, 43 },
    { 4, 39, 4, 49 },
  })
end)
