local runner = require("tests.queries.runner")

runner.test({
  name = "html",
  provider = "treesitter",
  file = "tests/queries/html/index.html",
  filetype = "htmldjango",
  ranges = {
    { 10, 14, 10, 47 },
    { 11, 16, 11, 39 },
  },
})
