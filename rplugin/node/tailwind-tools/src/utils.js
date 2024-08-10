const path = require("node:path");

function getNodeModuleResolver(rootDir) {
  return (modulePath) => {
    const absolutePath = path.join(rootDir, "node_modules", modulePath);
    const _module = require(absolutePath);
    const { default: _default } = _module;
    return _default ? _default : _module;
  };
}

const classNameMap = {
  fontSize: "text",
  fontWeight: "font",
  fontFamilly: "font",
  lineHeight: "leading",
  keyframes: "animate",
  animation: "animate",
  aspectRation: "aspect",
  letterSpacing: "tracking",
  backgroundSize: "bg",
  backgroundImage: "bg",
  backgroundPosition: "bg",
  borderWidth: "border",
  borderRadius: "rounded",
  gridAutoRows: "auto-rows",
  gridAutoColumns: "auto-cols",
  gridTemplateRows: "grid-rows",
  gridTemplateColumns: "grid-cols",
  textDecorationColor: "decoration",
  textDecorationThickness: "decoration",
  textUnderlineOffset: "underline-offset",
  zIndex: "z",
};

const nameReplacements = [
  ["grid-column", "col"],
  ["grid-row", "row"],
  ["background", "bg"],
  ["width", "w"],
  ["height", "h"],
  ["padding", "p"],
  ["margin", "m"],
  ["-color", ""],
];

function camelToKebabCase(camel) {
  return camel.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase();
}

function normalizeClassName(name) {
  const mapping = classNameMap[name];

  if (mapping) return mapping;

  let kebabName = camelToKebabCase(name);

  for (const [name, replacement] of nameReplacements) {
    kebabName = kebabName.replace(name, replacement);
  }

  return kebabName;
}

function mergeClass(key, value) {
  return value === "DEFAULT" ? key : key + "-" + value;
}

function isColorClass(name) {
  return name === "fill" || name === "stroke" || name.match(/[cC]olor/);
}

module.exports = {
  getNodeModuleResolver,
  normalizeClassName,
  mergeClass,
  isColorClass,
};
