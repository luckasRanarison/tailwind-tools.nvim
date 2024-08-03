const fs = require("fs");
const path = require("path");

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
    const tailwindPath = path.join(cwd, "node_modules/tailwindcss");

    if (!fs.existsSync(tailwindPath)) return;

    const resolveFnPath = path.join(tailwindPath, "resolveConfig");
    const resolveConfig = require(resolveFnPath);
    const projectConfigPath = path.join(cwd, "tailwind.config.js");

    let projectConfig = {};

    if (fs.existsSync(projectConfigPath)) {
      projectConfig = await import(projectConfigPath);
    }

    return resolveConfig(projectConfig.default ?? projectConfig);
  }
}

module.exports = Plugin;
