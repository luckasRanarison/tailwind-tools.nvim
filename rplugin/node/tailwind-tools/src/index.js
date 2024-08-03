const fs = require("node:fs");
const path = require("node:path");
const { getNodeModuleResolver } = require("./utils");

class Plugin {
  /**
   * @param {import("neovim").NvimPlugin} plugin
   */
  constructor(plugin) {
    this.nvim = plugin.nvim;

    // TODO: Register VimL functions for:
    // - Returning the processed config entries
    // - Expanding the classname to css

    plugin.registerFunction("GetTailwindConfig", this.getRawConfig.bind(this), {
      sync: true,
    });
  }

  async getRawConfig() {
    const cwd = await this.nvim.call("getcwd");
    const tailwindPath = path.join(cwd, "node_modules", "tailwindcss");

    if (!fs.existsSync(tailwindPath)) return;

    const _require = getNodeModuleResolver(cwd);
    const resolveConfig = _require("tailwindcss/resolveConfig");
    const loadConfig = _require("tailwindcss/lib/public/load-config").default;

    const configExtensions = ["js", "ts", "cjs"];
    const configPath = configExtensions
      .map((ext) => path.join(cwd, `tailwind.config.${ext}`))
      .find((filePath) => fs.existsSync(filePath));

    return resolveConfig(configPath ? loadConfig(configPath) : {});
  }
}

module.exports = Plugin;
