module.exports = {
  apps: [{
    name: 'tutorial-2',
    script: './index.js'
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
