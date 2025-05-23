local M = {}

local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local classes = require("tailwind-tools.classes")

---@class LookupTable
---@field prefix string
---@field normal string[]
---@field sorted string[]
---@field reverse table<string, integer>

local units = config.options.keymaps.smart_increment.units

---@param tbl {prefix: string?, values: string[]}
---@return LookupTable
local function make_lookup_table(tbl)
  local reverse = {}

  for key, value in pairs(tbl.values) do
    reverse[value] = key
  end

  local sorted = vim.deepcopy(tbl.values)

  table.sort(sorted, function(a, b) return #a > #b end)

  return {
    prefix = tbl.prefix,
    normal = tbl.values,
    reverse = reverse,
    sorted = sorted,
  }
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

---@param cursor number[]
local function find_range_at_cursor(cursor)
  local ranges = classes.get_ranges(0)
  local cursor_row = unpack(cursor)

  for _, range in pairs(ranges) do
    local range_row = unpack(range)
    if range_row == cursor_row then return range end
  end
end

---@param subline string
---@param lookup_tables LookupTable[]
local function find_best_handler(subline, lookup_tables)
  local handler

  for _, lookup_table in pairs(lookup_tables) do
    local start

    for _, term in pairs(lookup_table.sorted) do
      if lookup_table.prefix then
        start = subline:find(lookup_table.prefix)
      else
        start = subline:find(term)
      end

      if start and (not handler or start < handler.start) then
        handler = { start = start, lookup_table = lookup_table }
        if not lookup_table.prefix then handler.term = { col = start - 1, term = term } end
      end

      if lookup_table.prefix then break end
    end
  end

  return handler
end

---@param params { lookup_tables: LookupTable[] , step: number,  fallback: function }
local function make_step_fn(params)
  return function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row, cursor_col = cursor[1] - 1, cursor[2]
    local word_col = get_cursor_word() or cursor_col
    local line = vim.api.nvim_buf_get_lines(0, cursor_row, cursor_row + 1, true)[1]

    local range = find_range_at_cursor({ cursor_row, cursor_col })

    if not range then return params.fallback() end

    local _, _, range_end_row, range_end_col = unpack(range)
    local class_end_col = cursor_row == range_end_row and range_end_col or -1
    local subline = line:sub(word_col + 1, class_end_col)

    local handler = find_best_handler(subline, params.lookup_tables)

    if not handler then return params.fallback() end

    local lookup_table = handler.lookup_table
    local match = handler.term

    if not match then
      for _, term in pairs(lookup_table.sorted) do
        local col = subline:find(term)
        if col and (not match or col < match.col) then match = { col = col - 1, term = term } end
      end
    end

    if not match then return params.fallback() end

    local index = lookup_table.reverse[match.term]

    if params.step == 1 and index == #lookup_table.normal then return end
    if params.step == -1 and index == 1 then return end

    local start_col = cursor_col + (word_col - cursor_col) + match.col
    local end_col = cursor_col + (word_col - cursor_col) + match.col + #match.term
    local next_value = lookup_table.normal[index + params.step]

    -- move the cursor to the beginning of the match
    if cursor_col < start_col then vim.api.nvim_win_set_cursor(0, { cursor_row + 1, start_col }) end

    vim.api.nvim_buf_set_text(0, cursor_row, start_col, cursor_row, end_col, { next_value })

    local new_end_col = start_col + #next_value - 1

    -- move cursor back when length gets smaller
    if params.step == -1 and cursor_col > new_end_col then
      vim.api.nvim_win_set_cursor(0, { cursor_row + 1, new_end_col })
    end
  end
end

M.set_smart_increment = function()
  if state.smart_increment.active then return end

  local lookup_tables = {}

  for _, value in pairs(units) do
    lookup_tables[#lookup_tables + 1] = make_lookup_table(value)
  end

  local increment = make_step_fn({
    lookup_tables = lookup_tables,
    step = 1,
    fallback = function() vim.cmd.exe([["normal! \<c-a>"]]) end,
  })

  local decrement = make_step_fn({
    lookup_tables = lookup_tables,
    step = -1,
    fallback = function() vim.cmd.exe([["normal! \<c-x>"]]) end,
  })

  vim.keymap.set("n", "<c-a>", increment, { remap = true })
  vim.keymap.set("n", "<c-x>", decrement, { remap = true })

  vim.api.nvim_create_user_command("TailwindIncrement", increment, {})
  vim.api.nvim_create_user_command("TailwindDecrement", decrement, {})

  state.smart_increment.active = true
end

M.unset_smart_increment = function()
  vim.keymap.del("n", "<c-a>")
  vim.keymap.del("n", "<c-x>")

  vim.api.nvim_del_user_command("TailwindIncrement")
  vim.api.nvim_del_user_command("TailwindDecrement")

  state.smart_increment.active = false
end

return M
