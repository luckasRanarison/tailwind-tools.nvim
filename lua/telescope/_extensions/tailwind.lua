local log = require("tailwind-tools.log")
local utils = require("tailwind-tools.utils")
local plugin_config = require("tailwind-tools.config")

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")
local config = require("telescope.config").values

---@class TailwindTools.ClassEntry
---@field name string
---@field value any

local fg_prefixes = { "text", "border", "outline" }

local function get_hl_kind(class_name)
  for _, prefix in pairs(fg_prefixes) do
    if vim.startswith(class_name, prefix) then return "foreground" end
  end

  return "background"
end

local function class_picker()
  local classes = vim.fn.TailwindGetUtilities() --[[@as TailwindTools.ClassEntry[] | nil]]

  if not classes then return log.error("No project found") end

  local displayer = entry_display.create({
    separator = "",
    items = { { remaining = true } },
  })

  local finder = finders.new_table({
    results = classes,
    ---@param entry TailwindTools.ClassEntry
    entry_maker = function(entry)
      local highlight = "Normal"

      if type(entry.value) == "string" then
        local r, g, b = utils.extract_color(entry.value)
        if r then
          local kind = get_hl_kind(entry.name)
          highlight = utils.set_hl_from(r, g, b, kind)
        end
      end

      return {
        value = entry,
        display = function() return displayer({ { entry.name, highlight } }) end,
        ordinal = entry.name,
      }
    end,
  })

  local previewer = previewers.new_buffer_previewer({
    title = "Preview",
    define_preview = function(self, entry)
      local bufnr = self.state.bufnr
      local css = vim.fn.TailwindExpandUtilities({ entry.value.name })

      if type(css) == "string" then
        vim.bo[bufnr].ft = "css"
        vim.api.nvim_buf_set_text(bufnr, 0, -1, 0, -1, vim.split(css, "\n"))
        entry.value.css = css
      end
    end,
  })

  local attach_mappings = function()
    actions.select_default:replace(function(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      local name = selection.value.name
      local css = selection.value.css or ""

      actions.close(prompt_bufnr)

      plugin_config.options.telescope.utilities.callback(name, css)
    end)

    return true
  end

  pickers
    .new({}, {
      prompt_title = "Tailwind classes",
      finder = finder,
      sorter = config.generic_sorter(),
      previewer = previewer,
      attach_mappings = attach_mappings,
    })
    :find()
end

return require("telescope").register_extension({
  setup = function() end,
  exports = {
    utilities = class_picker,
  },
})
