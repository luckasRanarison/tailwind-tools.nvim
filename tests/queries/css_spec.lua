local runner = require("tests.queries.runner")

runner.test({
  name = "css",
  provider = "treesitter",
  file = "tests/queries/css/style.css",
  ranges = {
    { 5, 9, 5, 34 },
    { 9, 9, 10, 37 },
  },
})
