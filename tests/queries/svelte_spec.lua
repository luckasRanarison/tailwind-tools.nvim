local spec = {
  name = "svelte",
  provider = "treesitter",
  file = "tests/queries/svelte/test.svelte",
  ranges = {
    { 4, 12, 4, 26 },
    { 5, 14, 5, 41 },
    { 8, 17, 8, 27 },
  },
}

require("tests.queries.runner").test(spec)
