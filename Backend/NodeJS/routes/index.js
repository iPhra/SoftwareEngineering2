const auth = require('./auth');

module.exports = (app) => {
    app.use('/auth', auth)
};
