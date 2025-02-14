local runner = require("tests.queries.runner")

runner.test({
  name = "heex",
  provider = "treesitter",
  file = "tests/queries/heex/index.html.heex",
  ranges = {
    { 0, 12, 0, 27 },
    { 1, 13, 1, 20 },
    { 2, 12, 5, 4 },
  },
})
