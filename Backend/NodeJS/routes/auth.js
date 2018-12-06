const express = require('express');
const router = express.Router();
const Validator = require('../schemas/validator');
const validateRequest = Validator();
const authManager = require('../controllers/authManager');

router.post('/reg/single', validateRequest, function(req, res) {
    authManager(req.body, res);
});


module.exports = router;
