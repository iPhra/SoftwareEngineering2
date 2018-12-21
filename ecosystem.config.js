module.exports = {
  apps: [{
    name: 'data4help',
    script: './Backend/NodeJS/bin/www'
  }],
  deploy: {
    production: {
      user: 'ubuntu',
      host: '52.57.95.222',
      key: '~/.ssh/d4h.pem',
      ref: 'origin/master',
      repo: 'git@github.com:iphra/LorenzoMolteniNegri.git',
      path: '/home/ubuntu/Server',
      'post-deploy': 'npm install && pm2 startOrRestart ecosystem.config.js'
    }
  }
}
