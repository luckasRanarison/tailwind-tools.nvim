local M = {}

local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local classes = require("tailwind-tools.classes")

---@class LookupTable
---@field normal string[]
---@field sorted string[]
---@field reverse table<string, integer>

local untis = config.options.keymaps.smart_increment.units

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

local function get_cursor_word()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local col = cursor[2]
  local line = vim.api.nvim_get_current_line()

  local front = line:sub(1, col + 1):reverse()
  local back = line:sub(col + 1)

  local _, f_end = front:find("^[%w%-]+")
  local _, b_end = back:find("^[%w%-]+")

  if not f_end or not b_end then return end

  local w_start = col - f_end + 1
  local w_end = col + b_end

  return w_start, w_end
end

---@param lookup_table LookupTable
---@param step number
---@param range number[]
local function make_step_fn(lookup_table, step, range)
  return function()
    local _, _, range_end_row, range_end_col = unpack(range)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row, cursor_col = cursor[1] - 1, cursor[2]
    local class_end_col = cursor_row == range_end_row and range_end_col or -1
    local word_col = get_cursor_word() or cursor_col

    local text = vim.api.nvim_buf_get_text(0, cursor_row, word_col, cursor_row, class_end_col, {})

    local match

    for _, term in pairs(lookup_table.sorted) do
      local col = text[1]:find(term)
      if col and (not match or col < match.col) then match = { col = col - 1, term = term } end
    end

    if not match then return end

    local index = lookup_table.reverse[match.term]

    if step == 1 and index == #lookup_table.normal then return end
    if step == -1 and index == 1 then return end

    local start_col = cursor_col + (word_col - cursor_col) + match.col
    local end_col = cursor_col + (word_col - cursor_col) + match.col + #match.term
    local next_value = lookup_table.normal[index + step]

    -- move the cursor to the beginning of the match
    if cursor_col < start_col then vim.api.nvim_win_set_cursor(0, { cursor_row + 1, start_col }) end

    vim.api.nvim_buf_set_text(0, cursor_row, start_col, cursor_row, end_col, { next_value })

    local new_end_col = start_col + #next_value - 1

    -- move cursor back when length gets smaller
    if step == -1 and cursor_col > new_end_col then
      vim.api.nvim_win_set_cursor(0, { cursor_row + 1, new_end_col })
    end
  end
end

---@param range number[]
local function set_smart_mappings(range)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local w_col = get_cursor_word()

  local text = vim.api.nvim_buf_get_text(0, row, w_col or col, row, -1, {})

  local handler

  for _, entry in pairs(untis) do
    for _, term in pairs(entry.values) do
      if entry.prefix then term = string.format("%s-%s", entry.prefix, term) end

      local start = text[1]:find(term, 1, true)

      if start and (not handler or start < handler.start) then
        handler = { start = start, entry = entry }
      end
    end
  end

  if handler then
    local lookup_table = make_lookup_table(handler.entry.values)
    vim.keymap.set("n", "<c-a>", make_step_fn(lookup_table, 1, range), { remap = true })
    vim.keymap.set("n", "<c-x>", make_step_fn(lookup_table, -1, range), { remap = true })
    if not state.smart_increment.active then state.smart_increment.active = true end
  end
end

local function unset_smart_mappings()
  vim.keymap.del("n", "<c-a>")
  vim.keymap.del("n", "<c-x>")
  state.smart_increment.active = false
end

M.set_smart_increment = function()
  vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    callback = function()
      local ranges = classes.get_ranges(0)

      for _, range in pairs(ranges) do
        if is_cursor_in_range(range) then
          set_smart_mappings(range) -- make sure to override prev mapping
          return
        end
      end

      if state.smart_increment.active then unset_smart_mappings() end
    end,
  })
end

return M
