local spec = {
  name = "astro",
  provider = "treesitter",
  file = "tests/queries/astro/index.astro",
  ranges = {
    { 4, 17, 4, 42 },
    { 6, 12, 6, 26 },
    { 7, 14, 7, 41 },
    { 9, 33, 9, 43 },
  },
}

require("tests.queries.runner").test(spec)
