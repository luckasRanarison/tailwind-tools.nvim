local runner = require("tests.queries.runner")

runner.test({
  name = "rust-leeptos",
  provider = "luapattern",
  file = "tests/queries/rust/leeptos.rs",
  ranges = {
    { 10, 20, 10, 29 },
    { 12, 23, 12, 65 },
  },
})

runner.test({
  name = "rust-dioxus",
  provider = "luapattern",
  file = "tests/queries/rust/dioxus.rs",
  ranges = {
    { 11, 20, 11, 80 },
  },
})
