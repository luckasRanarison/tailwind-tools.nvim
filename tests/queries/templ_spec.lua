local runner = require("tests.queries.runner")

runner.test({
  name = "templ",
  provider = "treesitter",
  file = "tests/queries/templ/test.templ",
  ranges = {
    { 3, 14, 3, 23 },
    { 4, 18, 4, 27 },
  },
})
