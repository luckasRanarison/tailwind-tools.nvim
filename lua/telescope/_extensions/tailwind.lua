local log = require("tailwind-tools.log")
local utils = require("tailwind-tools.utils")
local classes = require("tailwind-tools.classes")
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

local function utility_picker()
  local utilities = vim.fn.TailwindGetUtilities() --[[@as TailwindTools.ClassEntry[] | nil]]

  if utilities == vim.NIL then return log.error("No project found") end

  local displayer = entry_display.create({
    separator = "",
    items = { { remaining = true } },
  })

  local finder = finders.new_table({
    results = utilities,
    ---@param entry TailwindTools.ClassEntry
    entry_maker = function(entry)
      local highlight = "Normal"

      for _, value in pairs(entry.value) do
        if type(value) == "string" then
          local r, g, b = utils.extract_color(value)

          if r then
            local kind = get_hl_kind(entry.name)
            highlight = utils.set_hl_from(r, g, b, kind)
          end
        end
      end

      return {
        value = entry,
        ordinal = entry.name,
        display = function() return displayer({ { entry.name, highlight } }) end,
      }
    end,
  })

  local previewer = previewers.new_buffer_previewer({
    title = "CSS Output",
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
      prompt_title = "Tailwind utilities",
      finder = finder,
      sorter = config.generic_sorter(),
      previewer = previewer,
      attach_mappings = attach_mappings,
    })
    :find()
end

local function class_picker()
  local bufnr = vim.api.nvim_get_current_buf()
  local class_ranges = classes.get_ranges(bufnr)

  if #class_ranges == 0 then return log.info("No classes") end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  local entries = {}

  for _, range in pairs(class_ranges) do
    local start_row, start_col, end_row, end_col = unpack(range)
    local text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

    entries[#entries + 1] = { range = range, text = table.concat(text, "\n") }
  end

  local finder = finders.new_table({
    results = entries,
    entry_maker = function(entry)
      return {
        value = entry,
        ordinal = entry.text,
        display = entry.text,
        path = filename,
        lnum = entry.range[1] + 1,
      }
    end,
  })

  pickers
    .new({}, {
      prompt_title = "Tailwind classes",
      finder = finder,
      sorter = config.generic_sorter(),
      previewer = previewers.vim_buffer_vimgrep.new({}),
    })
    :find()
end

return require("telescope").register_extension({
  setup = function() end,
  exports = {
    classes = class_picker,
    utilities = utility_picker,
  },
})
