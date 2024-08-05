const path = require("node:path");

const getNodeModuleResolver = (rootDir) => (modulePath) =>
  require(path.join(rootDir, "node_modules", modulePath));

module.exports = {
  getNodeModuleResolver,
};
