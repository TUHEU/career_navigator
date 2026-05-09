/** @type {import("eslint").Linter.Config} */
module.exports = {
  root: true,
  ignorePatterns: ["dist/", "coverage/", "node_modules/"],
  env: {
    es2022: true,
    node: true,
    browser: false
  },
  parserOptions: {
    ecmaVersion: "latest",
    sourceType: "module"
  },
  extends: [],
  rules: {
    // Intentionally minimal until we install eslint plugins per package.
    "no-unused-vars": "warn",
    "no-console": "off"
  }
};
