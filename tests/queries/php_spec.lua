local spec = {
  name = "php",
  provider = "treesitter",
  file = "tests/queries/php/index.php",
  ranges = {
    { 10, 14, 10, 47 },
    { 11, 16, 11, 39 },
  },
}

require("tests.queries.runner").test(spec)
