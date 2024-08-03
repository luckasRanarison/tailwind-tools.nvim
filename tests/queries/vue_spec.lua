require("tests.queries.runner").test({
  name = "vue",
  provider = "treesitter",
  file = "tests/queries/vue/test.vue",
  ranges = {
    { 1, 21, 1, 40 },
    { 2, 16, 2, 43 },
    { 4, 39, 4, 49 },
  },
})
