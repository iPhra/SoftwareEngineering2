var nodemailer = require('nodemailer');

let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'data4helpsquad@gmail.com',
        pass: 'mauriziofixamf'
    }
});

var mailOptions = {
    from: 'data4helpsquad@gmail.com',
    to: 'moltek96@gmail.com',
    subject: 'Welcome to Data4Help',
    text: 'Activation link: http://127.0.0.1:3000/activ?activToken=1'
};

module.exports = {
    'mailOptions' : mailOptions,
    'transporter' : transporter
};
