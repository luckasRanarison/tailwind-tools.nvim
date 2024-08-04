local parsers = {
  "html",
  "css",
  "tsx",
  "astro",
  "php",
  "twig",
  "svelte",
  "vue",
  "htmldjango",
  "heex",
  "elixir",
  "javascript",
  "typescript",
  "templ",
}

vim.cmd.TSInstallSync(parsers)
vim.cmd.q()
