local runner = require("tests.queries.runner")

runner.test({
  name = "closure",
  provider = "luapattern",
  file = "tests/queries/clojure/test.cljs",
  ranges = {
    { 4, 9, 4, 14 },
    { 0, 6, 0, 11, delimiter = { pattern = "%.", raw = "." } },
    { 1, 9, 1, 14, delimiter = { pattern = "%.", raw = "." } },
    { 2, 3, 2, 8, delimiter = { pattern = "%.", raw = "." } },
    { 3, 6, 3, 11, delimiter = { pattern = "%.", raw = "." } },
  },
})
