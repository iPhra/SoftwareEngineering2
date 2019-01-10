module.exports = {
  apps : [
      {
        name: "Data4Help",
        script: "../bin/www.js",
        watch: true,
        env: {
            "PORT": 3000,
            "NODE_ENV": "development"
        },
        env_production: {
            "PORT": 3000,
            "NODE_ENV": "production",
        }
      }
  ]
};
