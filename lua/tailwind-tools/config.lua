---@diagnostic disable: unused-local

local M = {}

local units = require("tailwind-tools.units")

---@alias TailwindTools.ColorHint "foreground" | "background" | "inline"
---@alias TailwindTools.CmpHighlightHint "foreground" | "background"
---@alias TailwindTools.SettingsOption.DiagnosticSeveritySetting "ignore" | "warning" | "error"

---@class TailwindTools.SettingsOption.LintOption
---@field cssConflict? TailwindTools.SettingsOption.DiagnosticSeveritySetting
---@field invalidApply? TailwindTools.SettingsOption.DiagnosticSeveritySetting
---@field invalidScreen? TailwindTools.SettingsOption.DiagnosticSeveritySetting
---@field invalidVariant? TailwindTools.SettingsOption.DiagnosticSeveritySetting
---@field invalidConfigPath? TailwindTools.SettingsOption.DiagnosticSeveritySetting
---@field invalidTailwindDirective? TailwindTools.SettingsOption.DiagnosticSeveritySetting
---@field invalidSourceDirective? TailwindTools.SettingsOption.DiagnosticSeveritySetting
---@field recommendedVariantOrder? TailwindTools.SettingsOption.DiagnosticSeveritySetting

---@class TailwindTools.SettingsOption.ExperimentalOption
---@field classRegex? string[] | [string, string][]
---@field configFile? string | {[string]: string | string[]}

---@class TailwindTools.SettingsOption.FilesOption
---@field exclude? string[]

---@class TailwindTools.ServerOption
---@field override boolean
---@field settings TailwindTools.SettingsOption
---@field on_attach? vim.lsp.client.on_attach_cb
---@field root_dir? fun(fname: string): string | nil
---@field capabilities vim.lsp.ClientCapabilities

---@class TailwindTools.SettingsOption
---@field tailwindCSS? TailwindTools.SettingsOption
---@field inspectPort? number
---@field emmetCompletions? boolean
---@field includeLanguages? { [string]: string }
---@field classAttributes? string[]
---@field classFunctions? string[]
---@field suggestions? boolean
---@field hovers? boolean
---@field codeLens? boolean
---@field codeActions? boolean
---@field validate? boolean
---@field showPixelEquivalents? boolean
---@field rootFontSize? number
---@field colorDecorators? boolean
---@field lint? TailwindTools.SettingsOption.LintOption
---@field experimental? TailwindTools.SettingsOption.ExperimentalOption
---@field files? TailwindTools.SettingsOption.FilesOption

---@class TailwindTools.Option
---@field server TailwindTools.ServerOption
M.options = {
  server = {
    override = true,
    settings = {},
  },
  document_color = {
    enabled = true,
    ---@type TailwindTools.ColorHint
    kind = "inline",
    inline_symbol = "󰝤 ",
    debounce = 200,
  },
  conceal = {
    enabled = false,
    min_length = nil,
    symbol = "󱏿",
    highlight = {
      fg = "#38BDF8",
    },
  },
  cmp = {
    ---@type TailwindTools.CmpHighlightHint
    highlight = "foreground",
  },
  telescope = {
    utilities = {
      callback = function(_name, _css) end,
    },
  },
  extension = {
    queries = {},
    patterns = {},
  },
  keymaps = {
    smart_increment = {
      enabled = true,
      units = units,
    },
  },
}

return M
