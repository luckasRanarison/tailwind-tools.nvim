const fs = require("node:fs");
const path = require("node:path");
const utils = require("./utils");
const tailwind = require("./tailwind");

class Plugin {
  /**
   * @param {import("neovim").NvimPlugin} plugin
   */
  constructor(plugin) {
    this.nvim = plugin.nvim;

    plugin.registerFunction(
      "TailwindGetConfig",
      this.getTailwindConfig.bind(this),
      { sync: true },
    );

    plugin.registerFunction(
      "TailwindGetUtilities",
      this.getUtilities.bind(this),
      { sync: true },
    );

    plugin.registerFunction(
      "TailwindExpandUtilities",
      this.expandUtilities.bind(this),
      { sync: true },
    );
  }

  // TODO: Get the running language server root directory?
  getProjectRoot() {
    return this.nvim.call("getcwd");
  }

  async getTailwindConfig() {
    const rootDir = await this.getProjectRoot();
    const tailwindPath = path.join(rootDir, "node_modules", "tailwindcss");

    if (!fs.existsSync(tailwindPath)) return;

    const _require = utils.getNodeModuleResolver(rootDir);
    const resolveConfig = _require("tailwindcss/resolveConfig");
    const loadConfig = _require("tailwindcss/lib/public/load-config");

    const configExtensions = ["js", "ts", "cjs"];
    const configPath = configExtensions
      .map((ext) => path.join(rootDir, `tailwind.config.${ext}`))
      .find((filePath) => fs.existsSync(filePath));

    return resolveConfig(configPath ? loadConfig(configPath) : {});
  }

  /**
   * @returns {{name: string, value: any}[]}
   */
  async getUtilities() {
    const config = await this.getTailwindConfig();

    if (!config) return;

    const root = await this.getProjectRoot();
    const _require = utils.getNodeModuleResolver(root);
    const { theme } = config;
    const { corePlugins } = _require("tailwindcss/lib/corePlugins");
    const nameClass = _require("tailwindcss/lib/util/negateValue");
    const negateValue = _require("tailwindcss/lib/util/nameClass");
    const params = { theme, nameClass, negateValue };

    const results = {};

    for (const [key, plugin] of Object.entries(corePlugins)) {
      results[key] = tailwind.getUtilities(plugin, params);
    }

    return results;
  }

  /**
   * @param {string[]} classes
   */
  async expandUtilities(classes) {
    const config = await this.getTailwindConfig();

    if (!config) return;

    config.content = [{ raw: classes.join(" ") }];

    const rootDir = await this.getProjectRoot();
    const _require = utils.getNodeModuleResolver(rootDir);
    const postcss = _require("postcss");
    const tailwindcss = _require("tailwindcss");
    const processor = postcss(tailwindcss(config));

    return processor
      .process("@tailwind utilities", { from: undefined })
      .async()
      .then(({ css }) => css);
  }
}

module.exports = Plugin;
