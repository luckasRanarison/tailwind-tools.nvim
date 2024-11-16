local runner = require("tests.queries.runner")

runner.test({
  name = "javascript",
  provider = "treesitter",
  file = "tests/queries/javascript/test.js",
  ranges = {
    { 0, 4, 0, 10 },
    { 1, 5, 1, 25 },
    { 2, 11, 2, 36 },
    { 3, 3, 3, 39 },
    { 4, 9, 4, 34 },
  },
})

runner.test({
  name = "javascriptreact",
  provider = "treesitter",
  file = "tests/queries/javascript/Component.jsx",
  ranges = {
    { 6, 19, 7, 55 },
    { 9, 24, 9, 47 },
    { 13, 25, 13, 45 },
  },
})
