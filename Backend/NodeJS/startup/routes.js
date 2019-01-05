const auth = require('../routes/auth');
const settings = require('../routes/settings');
const data = require('../routes/data');
const req = require('../routes/req');
const error = require('../middlewares/error');


//binds express app to each route
module.exports = (app) => {
    app.use('/auth', auth);
    app.use('/settings', settings);
    app.use('/data', data);
    app.use('/req', req);
    app.use(error);
};
