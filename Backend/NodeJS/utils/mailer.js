const nodemailer = require('nodemailer');
const config = require('config');


const transporter = nodemailer.createTransport(config.get("transporter"));

module.exports = (req, activToken) => {
    const mailOptions = {
        from: config.get("email"),
        to: req.body.email,
        subject: 'Welcome to Data4Help',
        text: 'Activation link: ' + config.get("hostname") + 'auth/activ?activToken=' + activToken
    };

    //if we are in production or development
    if(process.env.NODE_ENV!=="test") {
        transporter.sendMail(mailOptions, (error) => {
            if(error) {
                console.log(error);
            }  else {
                console.log('Email sent to ' + req.body.email)
            }
        })
    }
};
