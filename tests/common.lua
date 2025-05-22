local M = {}

M.assert_cursor = function(expected_row, expected_col)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  assert.same(expected_row, row, "Mismatched row")
  assert.same(expected_col, col, "Mismatched col")
end

M.get_extmarks = function(bunfr, ns, details)
  local results = {}
  local extmarks = vim.api.nvim_buf_get_extmarks(bunfr, ns, 0, -1, { details = true })

  for _, ext in pairs(extmarks) do
    local data

    if details then
      data = {}

      for _, key in pairs(details) do
        data[key] = ext[4][key]
      end
    end

    if ext[4].end_row then
      results[#results + 1] = { ext[2], ext[3], ext[4].end_row, ext[4].end_col, data }
    else
      results[#results + 1] = { ext[2], ext[3], data }
    end
  end

  return results
end

return M
