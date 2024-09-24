local M = {}

---@class TailwindTools.ClassEntry
---@field name string
---@field value any

local function nil_wrap(fn)
  return function(args)
    local result = fn(args)
    if result ~= vim.NIL then return result end
  end
end

---@type fun(utilities: string[]): string?
---Expands utility classes to CSS using tailwindcss library from the current project.
---It uses PostCSS from the current project for TailwindCSS v3.
---
---TODO: Support for v4
M.expand_utilities = nil_wrap(vim.fn.TailwindExpandUtilities)

---@type fun(): TailwindTools.ClassEntry[]?
---Gets available utility classes for the current project.
---It is done by reading and processing the tailwind configuration file.
---
---TODO: Support for v4
M.get_utilities = nil_wrap(vim.fn.TailwindGetUtilities)

return M
