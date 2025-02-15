local runner = require("tests.queries.runner")

runner.test({
  name = "closure",
  provider = "treesitter",
  file = "tests/queries/clojure/test.cljs",
  ranges = {
    { 3, 8, 3, 15 },
    { 4, 8, 4, 18 },
    { 5, 17, 5, 24 },
  },
})
