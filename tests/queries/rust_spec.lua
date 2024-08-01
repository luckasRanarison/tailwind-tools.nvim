require("tests.queries.runner").test({
  name = "rust",
  provider = "luapattern",
  file = "tests/queries/rust/leeptos.rs",
  ranges = {
    { 10, 20, 10, 29 },
    { 12, 23, 12, 65 },
  },
})
