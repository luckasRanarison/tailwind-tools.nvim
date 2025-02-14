local runner = require("tests.queries.runner")

runner.test({
  name = "filters",
  provider = "treesitter",
  file = "tests/queries/heex/index.html.heex",
  filters = { sortable = true },
  ranges = {
    { 0, 12, 0, 27 },
  },
})
