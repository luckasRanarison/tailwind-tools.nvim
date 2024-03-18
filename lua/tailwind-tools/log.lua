local M = {}

local levels = vim.log.levels
local function notify(message, level) vim.notify("[tailwind-tools] " .. message, level) end

M.debug = function(message) notify(message, levels.DEBUG) end

M.info = function(message) notify(message, levels.INFO) end

M.warn = function(message) notify(message, levels.WARN) end

M.error = function(message) notify(message, levels.ERROR) end

return M
