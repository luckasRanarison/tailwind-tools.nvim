require("tests.queries.runner").test({
  name = "vue",
  provider = "treesitter",
  file = "tests/queries/vue/test.vue",
  ranges = {
    { 1, 14, 1, 28 },
    { 2, 16, 2, 43 },
    { 4, 39, 4, 49 },
  },
})
