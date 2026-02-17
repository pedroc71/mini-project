module.exports = [
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "script",
      globals: {
        require: "readonly",
        module: "readonly",
        process: "readonly",
        console: "readonly",
        setTimeout: "readonly"
      }
    },
    rules: {
      "no-undef": "error"
    }
  }
];
