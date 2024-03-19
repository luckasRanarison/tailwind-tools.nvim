local M = {}

local levels = vim.log.levels

local notify_fn = function(level)
  return function(message) vim.notify("[tailwind-tools] " .. message, level) end
end

M.debug = notify_fn(levels.DEBUG)
M.info = notify_fn(levels.INFO)
M.warn = notify_fn(levels.WARN)
M.error = notify_fn(levels.ERROR)

return M
