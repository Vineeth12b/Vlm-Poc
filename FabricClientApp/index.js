const express = require("express");
const app = express();
const port = 3000;

const createRecord = require("./src/createRecord");
const updateRecordOwnership = require("./src/updateRecordOwnership");
const queryRecordByChassisNumber = require("./src/queryRecordByChassisNumber");
const queryAllRecords = require("./src/queryAllRecords");
const queryRecordHistory = require("./src/queryRecordHistory");

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.set("title", "VLMCLIENT");

app.post("/createRecord", (req, res) => {
    createRecord.execute(
        req.body.vehicleDetails.engineNumber,
        req.body.vehicleDetails.chassisNumber,
        req.body.vehicleDetails.invoicedAmount,
        req.body.vehicleDetails.date,
        req.body.ownerDetails.name,
        req.body.ownerDetails.gender,
        req.body.ownerDetails.mobileNumber,
        req.body.ownerDetails.dateOfBirth,
        req.body.ownerDetails.aadharNumber,
        req.body.ownerDetails.addressProof,
        req.body.insuranceDetails.insurerCompany,
        req.body.insuranceDetails.insuredAmount)
    .then(() => {
      console.log("Record added");
      const result = {
        status: "Success",
        message: "Record added succcesfully"
      };
      res.json(result);
    })
    .catch((e) => {
      const result = {
        status: "error",
        message: "failed",
        error: e,
      };
      res.status(500).send(result);
    });
});


app.post("/updateRecordOwnership", (req, res) => {
  updateRecordOwnership.execute(
    req.query.chassisNumber,
    req.body.ownerDetails.name,
    req.body.ownerDetails.gender,
    req.body.ownerDetails.mobileNumber,
    req.body.ownerDetails.dateOfBirth,
    req.body.ownerDetails.aadharNumber,
    req.body.ownerDetails.addressProof)
  .then(() => {
    console.log("Record updated");
    const result = {
      status: "success",
      message: "Record updated succcesfully",
    };
    res.json(result);
  })
  .catch((e) => {
    const result = {
      status: "error",
      message: "failed",
      error: e,
    };
    res.status(500).send(result);
  });
});


app.get("/queryRecordByChassisNumber", (req, res) => {
    queryRecordByChassisNumber.execute(req.body.chassisNumber)
    .then((response) => {
      console.log("Retrieved record");
      const result = {
        status: "success",
        message: "Details of record Retrieved succcesfully",
        data: response
        
      };
      res.json(result);
    })
    .catch((e) => {
      const result = {
        status: "error",
        message: "failed",
        error: e,
      };
      res.status(500).send(result);
    });
});


app.get("/queryAllRecords", ( req,res) => {
    queryAllRecords.execute()
       .then((response) => {
         console.log("Queried all records");
         const result = {
           status: "success",
           message: "Queried all records succcesfully",
           data: response
         };
         res.json(result);
       })
       .catch((e) => {
         const result = {
           status: "error",
           message: "failed",
           error: e,
         };
         res.status(500).send(result);
       });
   });


   app.get('/queryRecordHistory', (req, res) => {
    queryRecordHistory.execute(req.body.chassisNumber)
    .then((response) => {
        console.log('Fethched record history');
        const result = {
            status: 'success',
            message:' Fethched record history succesfully',
            data: response
        };
        res.json(result);
    })
    .catch((e) => {
        const result = {
            status: 'error',
            message: 'failed',
            error: e
        };
        res.status(500).send(result);
    });
});


app.listen(port, () => console.log(" Listening  port  3000 "));