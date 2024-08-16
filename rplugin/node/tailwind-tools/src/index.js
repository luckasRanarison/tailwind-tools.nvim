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
      "TailwindGetUtilities",
      this.getUtilities.bind(this),
      { sync: true }
    );

    plugin.registerFunction(
      "TailwindExpandUtilities",
      this.expandUtilities.bind(this),
      { sync: true }
    );
  }

  /**
   * @returns {Promise<string>}
   */
  async getProjectRoot() {
    let currentDir = await this.nvim.call("expand", "%:p:h");

    while (true) {
      const parentDir = path.dirname(currentDir);

      if (parentDir === currentDir) break;
      if (this.findConfigPath(currentDir)) return currentDir;

      currentDir = parentDir;
    }

    return currentDir;
  }

  findConfigPath(directory) {
    const configFiles = [
      "tailwind.config.js",
      "tailwind.config.ts",
      "tailwind.config.cjs",
    ];

    return configFiles
      .map((filename) => path.join(directory, filename))
      .find((filePath) => fs.existsSync(filePath));
  }

  async getTailwindConfig() {
    const rootDir = await this.getProjectRoot();
    const tailwindPath = path.join(rootDir, "node_modules", "tailwindcss");

    if (!fs.existsSync(tailwindPath)) return;

    const _require = utils.getNodeModuleResolver(rootDir);
    const resolveConfig = _require("tailwindcss/resolveConfig");
    const loadConfig = _require("tailwindcss/lib/public/load-config");
    const configPath = this.findConfigPath(rootDir);

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
    const { corePlugins } = _require("tailwindcss/lib/corePlugins");
    const negateValue = _require("tailwindcss/lib/util/negateValue");
    const nameClass = _require("tailwindcss/lib/util/nameClass");
    const params = { theme: config.theme, nameClass, negateValue };

    const utilties = {};

    for (const [key, plugin] of Object.entries(corePlugins)) {
      utilties[key] = tailwind.getUtilities(plugin, params);
    }

    return Object.values(utilties).flatMap((values) =>
      Object.entries(values).map(([name, value]) => ({
        name: name.slice(1), // remove the dot
        value,
      }))
    );
  }

  /**
   * @param {string[]} classes
   * @returns {Promise<string>}
   */
  async expandUtilities(classes) {
    const config = await this.getTailwindConfig();

    if (!config) return;

    config.content = [{ raw: classes.join(" ") }];

    const rootDir = await this.getProjectRoot();
    const _require = utils.getNodeModuleResolver(rootDir);
    const postcss = _require("postcss");
    const tailwind = _require("tailwindcss");
    const processor = postcss(tailwind(config));

    return processor
      .process("@tailwind utilities", { from: undefined })
      .async()
      .then(({ css }) => css);
  }
}

module.exports = Plugin;
