-- Used as an in-memory cache that keeps track
-- of whatever paths where detected while using
-- Neovim.
local M = { cache = {} }

-- Sort by length so more specific cache
-- directories hit faster.
M.sort = function()
  local keys = {}

  for key in pairs(M.cache) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b) return #a > #b end)

  return keys
end

-- Try to get a cache hit. Returns nil if no hit.
M.check = function(file_name)
  local sorted_keys = M.sort()

  for _, key in ipairs(sorted_keys) do
    if string.find(file_name, key, 1, true) then return M.cache[key] end
  end

  return nil
end

return M
