const auth = require('./auth');
const settings = require('./settings');

module.exports = (app) => {
    app.use('/auth', auth);
    app.use('/settings', settings)
};
