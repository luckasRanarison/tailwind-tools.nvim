local runner = require("tests.queries.runner")

runner.test({
  name = "typescript",
  provider = "treesitter",
  file = "tests/queries/typescript/test.ts",
  ranges = {
    { 0, 5, 0, 25 },
    { 1, 11, 1, 36 },
    { 2, 3, 2, 20 },
    { 3, 3, 3, 20 },
    { 4, 9, 4, 34 },
  },
})
