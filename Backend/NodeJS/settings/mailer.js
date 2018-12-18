//@todo Mettere dominio della mail al posto di 127.0.0.1

const nodemailer = require('nodemailer');
const config = require('config');


const transporter = nodemailer.createTransport(config.get("transporter"));

module.exports = (req, activToken) => {
    const mailOptions = {
        from: config.get("email"),
        to: req.body.email,
        subject: 'Welcome to Data4Help',
        text: 'Activation link: http://127.0.0.1:3000/auth/activ?activToken=' + activToken
    };

    transporter.sendMail(mailOptions, (error) => {
        if(error) {
            //@todo handle error
            console.log(error);
        }  else {
            console.log('Email sent to ' + req.body.email)
        }
    })
};
