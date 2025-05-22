local M = {}

local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local classes = require("tailwind-tools.classes")

---@class LookupTable
---@field normal string[]
---@field sorted string[]
---@field reverse table<string, integer>

local untis = {
  { values = config.options.keymaps.smart_increment.units.range },
  { values = config.options.keymaps.smart_increment.units.scale },
  { values = config.options.keymaps.smart_increment.units.size },
}

---@param tbl string[]
---@return LookupTable
local function make_lookup_table(tbl)
  local reverse = {}

  for key, value in pairs(tbl) do
    reverse[value] = key
  end

  local sorted = vim.deepcopy(tbl)

  table.sort(sorted, function(a, b) return #a > #b end)

  return { normal = tbl, reverse = reverse, sorted = sorted }
end

---@param range number[]
local function is_cursor_in_range(range)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local s_row, s_col, e_row, e_col = unpack(range)

  return (row > s_row or (row == s_row and col >= s_col))
    and (row < e_row or (row == e_row and col <= e_col))
end

---@param lookup_table LookupTable
---@param step number
---@param range number[]
local function make_step_fn(lookup_table, step, range)
  return function()
    local _, _, re_row, re_col = unpack(range)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]
    local te_col = row == re_row and re_col or -1
    local text = vim.api.nvim_buf_get_text(0, row, col, row, te_col, {})

    local match

    for _, value in pairs(lookup_table.sorted) do
      local start = text[1]:find(value, 1, true)

      if start and (not match or start < match.start) then
        match = { start = start, value = value }
      end
    end

    if not match then return end

    local index = lookup_table.reverse[match.value]

    if step == 1 and index == #lookup_table.normal then return end
    if step == -1 and index == 1 then return end

    local s_col = col + match.start - 1
    local e_col = col + match.start + #match.value - 1
    local next_value = lookup_table.normal[index + step]

    vim.api.nvim_win_set_cursor(0, { row + 1, col + match.start - 1 })
    vim.api.nvim_buf_set_text(0, row, s_col, row, e_col, { next_value })
  end
end

---@param range number[]
local function set_smart_mappings(range)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local text = vim.api.nvim_buf_get_text(0, row, col, row, -1, {})[1]

  local handler

  for _, entry in pairs(untis) do
    for _, term in pairs(entry.values) do
      local start = text:find(term, 1, true)

      if start and (not handler or start < handler.start) then
        handler = { start = start, values = entry.values }
      end
    end
  end

  if handler then
    local lookup_table = make_lookup_table(handler.values)
    vim.keymap.set("n", "<c-a>", make_step_fn(lookup_table, 1, range), { remap = true })
    vim.keymap.set("n", "<c-x>", make_step_fn(lookup_table, -1, range), { remap = true })
  end
end

local function unset_smart_mappings()
  vim.keymap.del("n", "<c-a>")
  vim.keymap.del("n", "<c-x>")
end

M.set_smart_increment = function()
  vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    callback = function()
      local ranges = classes.get_ranges(0)

      for _, range in pairs(ranges) do
        if is_cursor_in_range(range) then
          set_smart_mappings(range) -- make sure to override prev mapping
          if not state.smart_increment.active then state.smart_increment.active = true end
          return
        end
      end

      if state.smart_increment.active then
        pcall(unset_smart_mappings) -- FIXME: should not be wrapped
        state.smart_increment.active = false
      end
    end,
  })
end

return M
