const jwt = require('jsonwebtoken');
const config = require('config');


module.exports = () => {

    // return the authentication middleware
    return async (req, res, next) => {
        try {
            const decoded = await jwt.verify(req.get("x-authToken"), config.get('jwtPrivateKey'));
            req.body.userid = decoded.userid;
            req.body.usertype = decoded.usertype;
            next()
        } catch(err) {
            return res.status(401).send({error: "Authentication failed"});
        }
    }
};