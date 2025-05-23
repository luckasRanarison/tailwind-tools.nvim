local utils = require("tailwind-tools.utils")
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
  if cache.is_monorepo == nil then
    local repo_root = utils.get_repo_root()

    -- If nil is returned it means no root
    -- of the repo was detected, so there is
    -- no way to really know if we are dealing
    -- with a monorepo or not. This will make
    -- the plugin fallback to default detection.
    if not repo_root then
      cache.is_monorepo = false
      return nil
    end

    -- Some monorepos use pnpm-workspace.yaml without
    -- any reference to "workspaces" in the `package.json`,
    -- so let's check for that before reading the `package.json`
    local repo_pnpm_workspace = repo_root .. "/pnpm-workspace.yaml"
    if vim.fn.filereadable(repo_pnpm_workspace) == 1 then
      cache.is_monorepo = true
    else
      -- Not a pnpm monorepo, so let's check for the
      -- git-root `package.json` file for "workspaces"
      local repo_package_json = repo_root .. "/package.json"

      if vim.fn.filereadable(repo_package_json) ~= 1 then
        -- Same as above. If we can't access the root
        -- repo package.json file, then we don't know
        -- if this is a monorepo or not. So return nil
        -- and fallback to default detection.
        cache.is_monorepo = false
        return nil
      else
        local file = io.open(repo_package_json, "r")

        if file then
          local content = file:read("*a")
          file:close()

          -- Check if there is a "workspaces" property
          -- configured in the repo's root package.json
          -- file. This is how monorepo configurations are
          -- created, so if "workspaces" exists, then we
          -- are dealing with a monorepo. Therefore, if a
          -- "workspaces" property is NOT detected, we should
          -- stop here, return nil and fallback to default
          -- detection.
          if not content:find("workspaces") then
            cache.is_monorepo = false
            return nil
          else
            cache.is_monorepo = true
          end
        else
          cache.is_monorepo = false
          return nil
        end
      end
    end
  end

  -- If the repo is not a monorepo then we can
  -- stop here and fallback to default detection.
  if cache.is_monorepo == false then return nil end

  -- Check cache first.
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
