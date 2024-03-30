local common = require("tests.queries.common")
local runner = common.Runner:new("tests/queries/css/style.css")

describe("queries css:", function()
  runner:classes(2)
  runner:ranges({
    { 5, 9, 5, 34 },
    { 9, 9, 10, 37 },
  })
end)
