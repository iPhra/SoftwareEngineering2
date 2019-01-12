const Router = require('express-promise-router');
const db = require('../utils/dbconnection');
const authenticator = require('../middlewares/authenticator');

const router = new Router();


//upload data of a PrivateUser
router.post('/upload', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    //if he's not logged in or he's not a PrivateUser
    if (req.body.usertype!=="PrivateUser")
        return res.status(401).send({error: "You need to login with a Single User account"});

    await(db.query('BEGIN'));

    let text;
    let values;
    let rows;

    //import each observation into the database
    for(let i=0; i<req.body.types.length; i++) {
        for(let j=0; j<req.body.values[i].length; j++) {
            text = "SELECT * FROM userdata WHERE userid=$1 and datatype=$2 and timest=$3";
            values = [userID, req.body.types[i], req.body.timestamps[i][j]];
            rows = await db.query(text, values);

            //if not present, i import it
            if(rows.rowCount===0) {
                text = "INSERT INTO userdata VALUES($1, $2, $3, $4)";
                values = [userID, req.body.types[i], req.body.timestamps[i][j], req.body.values[i][j]];
                await db.query(text, values);
            }
        }
    }

    await(db.query('COMMIT'));
    res.status(200).send({message: "Data Imported"});
});


//get statistics of a PrivateUser to be compared with others
router.post('/stats/avg', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    //if he's not logged in or he's not a PrivateUser
    if (req.body.usertype!=="PrivateUser")
        return res.status(401).send({error: "You need to login with a Single User account"});

    //get datapoints from the database
    let response = [];
    let obj;
    let text;
    let values;
    let rows;

    for(let i=0; i<req.body.types.length; i++) {

        obj = {type:req.body.types[i]};

        text = "SELECT avg(value) as avg, min(value) as min, max(value) as max, date_part('month', timest) as month, date_part('year', timest) as year " +
            "FROM userdata WHERE userid=$1 and datatype=$2 " +
            "GROUP BY date_part('year', timest), date_part('month', timest) " +
            "ORDER BY date_part('year',timest), date_part('month', timest)";
        values = [userID, req.body.types[i]];
        rows = await db.query(text, values);

        //convert each value of avg, min and max from string to float
        for(let j=0; j<rows.rows.length; j++) {
            rows.rows[j].avg = parseFloat(rows.rows[j].avg);
            rows.rows[j].min = parseFloat(rows.rows[j].min);
            rows.rows[j].max = parseFloat(rows.rows[j].max);
        }

        obj["observations"] = rows.rows;

        text = "SELECT avg(value) as avg, date_part('month', timest) as month, date_part('year', timest) as year " +
            "FROM userdata WHERE datatype=$1 and (date_part('month',timest),date_part('year',timest)) in " +
                "(SELECT date_part('month',timest), date_part('year', timest) FROM userdata WHERE userid=$2)" +
            "GROUP BY date_part('year', timest), date_part('month', timest) " +
            "ORDER BY date_part('year',timest), date_part('month', timest)";
        values = [req.body.types[i], userID];
        rows = await db.query(text, values);

        //convert each value for the mean from string to float
        for(let j=0; j<rows.rows.length; j++) {
            rows.rows[j].avg = parseFloat(rows.rows[j].avg)
        }

        obj["others"] = rows.rows;

        //append observation to the response
        response.push(obj)
    }

    res.status(200).send({
        data : response
    })
});



module.exports = router;