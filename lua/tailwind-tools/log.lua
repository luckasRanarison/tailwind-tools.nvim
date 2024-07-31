local M = {}

local notify_fn = function(level)
  return ---@param message string
  function(message) vim.notify("[tailwind-tools] " .. message, level) end
end

M.debug = notify_fn(vim.log.levels.DEBUG)
M.info = notify_fn(vim.log.levels.INFO)
M.warn = notify_fn(vim.log.levels.WARN)
M.error = notify_fn(vim.log.levels.ERROR)

return M
