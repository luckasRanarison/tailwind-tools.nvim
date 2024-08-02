require("tests.queries.runner").test({
  name = "tsx",
  provider = "treesitter",
  file = "tests/queries/tsx/Component.tsx",
  ranges = {
    { 6, 19, 7, 55 },
    { 9, 24, 9, 47 },
    { 13, 24, 13, 46 },
  },
})
