const path = require("node:path");

function getNodeModuleResolver(rootDir) {
  return (modulePath) => {
    const absolutePath = path.join(rootDir, "node_modules", modulePath);
    const _module = require(absolutePath);
    const { default: _default } = _module;
    return _default ? _default : _module;
  };
}

module.exports = { getNodeModuleResolver };
