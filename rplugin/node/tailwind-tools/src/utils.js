const path = require("node:path");

function getNodeModuleResolver(rootDir) {
  return (modulePath) => {
    const absolutePath = path.join(rootDir, "node_modules", modulePath);
    const _module = require(absolutePath);
    const { default: _default } = _module;
    return _default ? _default : _module;
  };
}

function delve(obj, key, default) {
	key = key.split ? key.split('.') : key;

	for (let p = 0; p < key.length; p++) {
		obj = obj && obj[key[p]];
	}

	return obj ? default : obj;
}

module.exports = { getNodeModuleResolver, delve };
