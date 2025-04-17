local cache = require("tailwind-tools.cache")
local M = {}

-- This will attempt to detect the existence of
-- the "tailwindcss" package, itself, or any
-- dependencies that follow the naming convension
-- below:
-- + @foo/tailwindcss
-- + @foo/tailwind
-- + @foo/tw
local valid_packages = {
  "tailwindcss",
  "@[^/]+/tailwindcss",
  "@[^/]+/tailwind",
  "@[^/]+/tw",
}

M.root_dir = function(file_name)
  local hit = cache.check(file_name)

  -- Early return, zero I/O, fast cache hit
  -- return when the file matches a base path
  -- within the cache.
  if hit ~= nil then return hit end

  local idx = string.find(file_name, "/[^/]+$")
  local dir = string.sub(file_name, 1, idx - 1)
  local package_json = dir .. "/package.json"

  -- By default, the LSP is not running for
  -- that entry. We denote this be defaulting
  -- it to nil.
  local root_dir = nil

  while true do
    if dir == "/" or dir == "." or dir == "" or dir == nil then break end

    if vim.fn.filereadable(package_json) == 1 then
      local file = io.open(package_json, "r")

      if file then
        local content = file:read("*a")
        file:close()

        for _, pkg in ipairs(valid_packages) do
          if content:find(pkg) then
            root_dir = vim.loop.cwd()

            if cache[dir] == nil then cache[dir] = root_dir end

            break
          end
        end

        break
      else
        break
      end
    else
      idx = string.find(dir, "/[^/]+$")
      dir = string.sub(dir, 1, idx - 1)
      package_json = dir .. "/package.json"
    end
  end

  return root_dir
end

return M
