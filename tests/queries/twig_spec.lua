local spec = {
  name = "twig",
  provider = "treesitter",
  file = "tests/queries/twig/test.twig",
  ranges = {
    { 0, 12, 0, 26 },
    { 1, 14, 1, 41 },
    { 4, 17, 4, 27 },
  },
}

require("tests.queries.runner").test(spec)
