local runner = require("tests.queries.runner")

runner.test({
  name = "javascript",
  provider = "treesitter",
  file = "tests/queries/javascript/test.js",
  ranges = {
    { 0, 5, 0, 25 },
    { 1, 11, 1, 36 },
    { 2, 3, 2, 20 },
    { 3, 9, 3, 34 },
  },
})

runner.test({
  name = "javascriptreact",
  provider = "treesitter",
  file = "tests/queries/javascript/Component.jsx",
  ranges = {
    { 6, 19, 7, 55 },
    { 9, 24, 9, 47 },
    { 13, 24, 13, 46 },
  },
})
