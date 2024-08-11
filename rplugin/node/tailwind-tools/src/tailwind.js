/**
 * @see https://github.com/tailwindlabs/tailwindcss.com/blob/master/next.config.mjs
 */

function normalizeProperties(input) {
  if (typeof input !== "object") return input;
  if (Array.isArray(input)) return input.map(normalizeProperties);

  return Object.keys(input).reduce((newObj, key) => {
    const val = input[key];
    const newVal = typeof val === "object" ? normalizeProperties(val) : val;
    const kebabName = key.replace(
      /([a-z])([A-Z])/g,
      (_, p1, p2) => `${p1}-${p2.toLowerCase()}`
    );

    newObj[kebabName] = newVal;

    return newObj;
  }, {});
}

function getUtilities(plugin, params) {
  if (!plugin) return {};

  const utilities = {};

  const addUtilities = (utils) => {
    utils = Array.isArray(utils) ? utils : [utils];

    for (const util of utils) {
      for (const prop in util) {
        for (const p in util[prop]) {
          if (p.startsWith("@defaults")) delete util[prop][p];
        }

        utilities[prop] = normalizeProperties(util[prop]);
      }
    }
  };

  const matchUtilities = (matches, { values, supportsNegativeValues } = {}) => {
    if (!values) return;

    const modifierValues = Object.entries(values);

    if (supportsNegativeValues) {
      const negativeValues = [];

      for (const [key, value] of modifierValues) {
        const negatedValue = params.negateValue(value);
        if (negatedValue) negativeValues.push([`-${key}`, negatedValue]);
      }

      modifierValues.push(...negativeValues);
    }

    const result = Object.entries(matches).flatMap(([name, utilityFunction]) =>
      modifierValues
        .map(([modifier, value]) => {
          const className = params.nameClass(name, modifier);
          const declarations = utilityFunction(value, {
            includeRules(rules) {
              addUtilities(rules);
            },
          });

          if (declarations) return { [className]: declarations };
        })
        .filter((v) => v)
    );

    for (const obj of result) {
      for (const key in obj) {
        let deleteKey = false;

        for (const subkey in obj[key]) {
          if (subkey.startsWith("@defaults")) {
            delete obj[key][subkey];
            continue;
          }

          if (subkey.includes("&")) {
            result.push({ [subkey.replace(/&/g, key)]: obj[key][subkey] });
            deleteKey = true;
          }
        }

        if (deleteKey) delete obj[key];
      }
    }

    addUtilities(result);
  };

  plugin({
    addBase: () => {},
    addDefaults: () => {},
    addComponents: () => {},
    corePlugins: () => true,
    prefix: (x) => x,
    config: (option, defaultValue) => (option ? defaultValue : { future: {} }),
    theme: (key, defaultValue) =>
      key.split(".").reduce((prev, k) => prev && prev[k], params.theme) ??
      defaultValue,
    addUtilities,
    matchUtilities,
  });

  return utilities;
}

module.exports = { getUtilities };
