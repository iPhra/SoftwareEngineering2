const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'data4helpsquad@gmail.com',
        pass: 'mauriziofixamf'
    }
});

module.exports = (req, activToken) => {
    const mailOptions = {
        from: 'data4helpsquad@gmail.com',
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
