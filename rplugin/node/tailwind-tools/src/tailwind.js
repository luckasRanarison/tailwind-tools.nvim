/**
 * @see https://github.com/tailwindlabs/tailwindcss.com/blob/a29be90b7f2fb2560bfdc7778eb4de66af99d88a/next.config.js
 */

const utils = require("./utils");

function normalizeProperties(input) {
  if (typeof input !== "object") return input;
  if (Array.isArray(input)) return input.map(normalizeProperties);

  return Object.keys(input).reduce((newObj, key) => {
    const val = input[key];
    const newVal = typeof val === "object" ? normalizeProperties(val) : val;
    const kebabKey = key.replace(
      /([a-z])([A-Z])/g,
      (_, p1, p2) => `${p1}-${p2.toLowerCase()}`,
    );

    newObj[kebabKey] = newVal;

    return newObj;
  }, {});
}

function getUtilities(plugin, params) {
  if (!plugin) return {};

  const utilities = {};

  const addUtilities = (utils) => {
    utils = Array.isArray(utils) ? utils : [utils];

    for (let i = 0; i < utils.length; i++) {
      for (let prop in utils[i]) {
        for (let p in utils[i][prop]) {
          if (p.startsWith("@defaults")) {
            delete utils[i][prop][p];
          }
        }

        utilities[prop] = normalizeProperties(utils[i][prop]);
      }
    }
  };

  const matchUtilities = (matches, { values, supportsNegativeValues } = {}) => {
    if (!values) return;

    const modifierValues = Object.entries(values);

    if (supportsNegativeValues) {
      const negativeValues = [];

      for (let [key, value] of modifierValues) {
        const negatedValue = params.negateValue(value);

        if (negatedValue) {
          negativeValues.push([`-${key}`, negatedValue]);
        }
      }
      modifierValues.push(...negativeValues);
    }

    const result = Object.entries(matches).flatMap(
      ([name, utilityFunction]) => {
        return modifierValues
          .map(([modifier, value]) => {
            const declarations = utilityFunction(value, {
              includeRules(rules) {
                addUtilities(rules);
              },
            });

            if (!declarations) {
              return null;
            }

            return {
              [params.nameClass(name, modifier)]: declarations,
            };
          })
          .filter(Boolean);
      },
    );

    for (let obj of result) {
      for (let key in obj) {
        let deleteKey = false;

        for (let subkey in obj[key]) {
          if (subkey.startsWith("@defaults")) {
            delete obj[key][subkey];
            continue;
          }

          if (subkey.includes("&")) {
            result.push({
              [subkey.replace(/&/g, key)]: obj[key][subkey],
            });
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
    theme: (key, defaultValue) => utils.delve(params.theme, key, defaultValue),
    addUtilities,
    matchUtilities,
  });

  return utilities;
}

module.exports = { getUtilities };
