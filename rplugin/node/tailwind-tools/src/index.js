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

    plugin.registerFunction(
      "TailwindGetConfig",
      this.getExpandedConfig.bind(this),
      { sync: true }
    );

    plugin.registerFunction(
      "TailwindExpandUtilities",
      this.expandUtilities.bind(this),
      { sync: true }
    );
  }

  // TODO: Get the running language server root directory?
  getProjectRoot() {
    return this.nvim.call("getcwd");
  }

  async getRawConfig() {
    const rootDir = await this.getProjectRoot();
    const tailwindPath = path.join(rootDir, "node_modules", "tailwindcss");

    if (!fs.existsSync(tailwindPath)) return;

    const _require = getNodeModuleResolver(rootDir);
    const resolveConfig = _require("tailwindcss/resolveConfig");
    const loadConfig = _require("tailwindcss/lib/public/load-config").default;

    const configExtensions = ["js", "ts", "cjs"];
    const configPath = configExtensions
      .map((ext) => path.join(rootDir, `tailwind.config.${ext}`))
      .find((filePath) => fs.existsSync(filePath));

    return resolveConfig(configPath ? loadConfig(configPath) : {});
  }

  // TODO: expand utilities
  async getExpandedConfig() {}

  /**
   * @param {string[]} classes
   */
  async expandUtilities(classes) {
    const config = await this.getRawConfig();

    if (!config) return;

    const rootDir = await this.getProjectRoot();
    const _require = getNodeModuleResolver(rootDir);
    const postcss = _require("postcss");
    const tailwind = _require("tailwindcss");
    const processor = postcss(tailwind(config));

    config.content = [{ raw: `<div class="${classes.join(" ")}"></div>` }];

    return processor
      .process("@tailwind utilities", { from: undefined })
      .async()
      .then(({ css }) => css);
  }
}

module.exports = Plugin;
