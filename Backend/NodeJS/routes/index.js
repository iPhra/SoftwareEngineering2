const auth = require('./auth');
const settings = require('./settings');
const data = require('./data');



//binds express app to each route
module.exports = (app) => {
    app.use('/auth', auth);
    app.use('/settings', settings);
    app.use('/data', data)
};
