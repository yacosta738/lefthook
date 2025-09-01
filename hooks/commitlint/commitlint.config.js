/**
 * commitlint.config.js
 * @ref http://commitlint.js.org/
 * Default commitlint configuration for remote usage
 * @type {import('@commitlint/types').UserConfig}
 */
module.exports = {
	extends: ["@commitlint/config-conventional"],
	rules: {
		"header-max-length": [2, "always", 120],
		"body-max-line-length": [2, "always", 220],
	},
};