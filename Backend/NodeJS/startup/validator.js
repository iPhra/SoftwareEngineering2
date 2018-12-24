const validator = require('../middlewares/validator');


module.exports = (app) => {
    app.use(validator())
};