const fs = require("node:fs");
const path = require("node:path");
const utils = require("./utils");

class Plugin {
  /**
   * @param {import("neovim").NvimPlugin} plugin
   */
  constructor(plugin) {
    this.nvim = plugin.nvim;

    plugin.registerFunction(
      "TailwindGetConfig",
      this.getTailwindConfig.bind(this),
      { sync: true }
    );

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
    const flattenPalette = _require("tailwindcss/lib/util/flattenColorPalette");

    const { theme } = config;

    for (const key in theme) {
      if (utils.isColorClass(key)) theme[key] = flattenPalette(theme[key]);
    }

    const entries = Object.entries(theme).flatMap(([className, values]) => {
      const normalizedName = utils.normalizeClassName(className);
      return Object.entries(values).map(([subName, value]) => ({
        name: utils.mergeClass(normalizedName, subName),
        value: value,
      }));
    });

    return entries;
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
    const tailwind = _require("tailwindcss");
    const processor = postcss(tailwind(config));

    return processor
      .process("@tailwind utilities", { from: undefined })
      .async()
      .then(({ css }) => css);
  }
}

module.exports = Plugin;
