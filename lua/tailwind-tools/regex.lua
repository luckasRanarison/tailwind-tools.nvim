--- Credits to https://github.com/paolotiu/tailwind-intellisense-regex-list
return {
  clsx = { { "clsx\\(.*?\\)(?!\\])", "(?:'|\"|`)([^\"'`]*)(?:'|\"|`)" } },
  headless_ui_transition = { { "(?:enter|leave)(?:From|To)?=\\s*(?:\"|'|{`)([^(?:\"|'|`})]*)" } },
  classnames = { { "classnames\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" } },
  js_plain_object = { { ":\\s*?[\"'`]([^\"'`]*).*?," } },
  js_string_variable = { { "(?:const|let|var)\\s+[\\w$_][_\\w\\d]*\\s*=\\s*['\\\"](.*?)['\\\"]" } },
  js_string_variable_keywords = {
    "(?:\\b(?:const|let|var)\\s+)?[\\w$_]*(?:[Ss]tyles|[Cc]lasses|[Cc]lassna,s)[\\w\\d]*\\s*(?:=|\\+=)\\s*['\"]([^'\"]*)['\"]",
  },
  tailwind_rn = { { "tailwind\\('([^)]*)\\')", "(?:'|\"|`)([^\"'`]*)(?:'|\"|`)" } },
  cva = { { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" } },
  classlist = { { "classList={{([^;]*)}}", "\\s*?[\"'`]([^\"'`]*).*?:" } },
  tailwind_join = { { "twJoin\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" } },
  tailwind_merge = { { "(?:twMerge|twJoin)\\(([^;]*)[\\);]", "[`'\"`]([^'\"`;]*)[`'\"`]" } },
  tailwind_variants = { { "tv\\(([^)]*)\\)", "{?\\s?[\\w].*:\\s*?[\"'`]([^\"'`]*).*?,?\\s?}?" } },
  haml = {
    { 'class: ?"([^"]*)"', "([a-zA-Z0-9\\-:]+)" },
    { "(\\.[\\w\\-.]+)[\\n\\=\\{\\s]", "([\\w\\-]+)" },
  },
  jquery = { { "(?:add|remove)Class\\(([^)]*)\\)", "(?:'|\"|`)([^\"'`]*)(?:'|\"|`)" } },
  dom = { { "classList.(?:add|remove)\\(([^)]*)\\)", "(?:'|\"|`)([^\"'`]*)(?:'|\"|`)" } },
  comment_tagging = { { "@tw\\s\\*/\\s+[\"'`]([^\"'`]*)" } },
  blade_template = {
    { "@?class\\(([^)]*)\\)", "['|\"]([^'\"]*)['|\"]" },
    "(?:\"|')class(?:\"|')[\\s]*=>[\\s]*(?:\"|')([^\"']*)",
  },
  stimulus_css = { { "data-.*-class=['\"]([^'\"]*)" } },
  everywhere = { { "([a-zA-Z0-9\\-:]+)" } },
}
