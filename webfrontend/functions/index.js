/* eslint no-console: 0 */

const axios = require('axios');
const moment = require('moment');

function buildUrl(url, parameters) {
  var qs = '';
  for (var key in parameters) {
    var value = parameters[key];
    qs += encodeURIComponent(key) + '=' + encodeURIComponent(value) + '&';
  }
  if (qs.length > 0) {
    qs = qs.substring(0, qs.length - 1); //chop off last "&"
    url = url + '?' + qs;
  }
  return url;
}

/**
 * Send a request to Azure face service
 * @param activity
 * @param params Query params
 * @param data POST body
 * @returns {AxiosPromise}
 */
function azureRequest(activity, params, data, method = 'post', contentType = 'application/json') {
  let subscriptionKey = process.env.AZURE_KEY;

  let uriBase =
    `https://entrancescreen.cognitiveservices.azure.com/face/v1.0/${activity}`;

  // Perform the REST API call.
  return axios({
    method: method,
    url: buildUrl(uriBase, params),
    headers: {
      'Content-Type': contentType,
      'Ocp-Apim-Subscription-Key': subscriptionKey
    },
    data: data
  });
}

/**
 * Return map of persons (id => name)
 * @returns {Promise<Object>}
 */
async function loadPersons() {
  let persons = {};
  let response = await azureRequest(`persongroups/muehlemann/persons`, [], {}, 'get');
  response.data.forEach((item) => {
    persons[item.personId] = item.name;
  });
  return persons;
}

function sendMail(name, createdAt, imageurl, confidence) {
// notify via email
  const SparkPost = require('sparkpost');
  const client = new SparkPost(process.env.SPARKPOST_KEY);
  client.transmissions.send({
    options: {
      sandbox: false
    },
    content: {
      template_id: 'entrancescreen-person-detected',
    },
    substitution_data: {
      name: name,
      detectedAt: moment(createdAt).format('HH:mm:ss'),
      image: imageurl,
      confidence: (confidence * 100).toFixed(0)
    },
    recipients: [
      {address: 'silvan.muehlemann@muehlemann-popp.ch'}
    ]
  })
    .then(data => {
      console.log('Mail sent via Sparkpost');
      console.log(data);
    })
    .catch(err => {
      console.log('Mail sending via Sparkpost failed');
      console.log(err);
    });
}

const faceDetect = function (imageurl, filename, createdAt, db, oncomplete) {
// Request parameters.
    var params = {
      'returnFaceId': 'true',
      'returnFaceLandmarks': 'false',
      'recognitionModel': 'recognition_02',
      'returnRecognitionModel': true,
      'returnFaceAttributes':
        'age,gender,headPose,smile,facialHair,glasses,emotion,' +
        'hair,makeup,occlusion,accessories,blur,exposure,noise'
    };

    azureRequest('detect', params, {'url': imageurl}, 'post', 'application/json')
      .then((data) => {

        console.log('Face detected', data.data);

        let firestoreObj = {
          filename: filename,
          createdAt: createdAt,
          sentAt: new Date(),
          detectData: data.data,
          status: null
        };

        // if there is one face then try to identify
        if (data.data.length === 1) {
          console.log('Identify face via Azure');
          azureRequest('identify',
            [], {
              'faceIds': [data.data[0].faceId],
              'personGroupId': 'muehlemann'
            }).then(async (identifyData) => {
              let out = '';
              let persons = await loadPersons();

              let detectedPersonName = persons[identifyData.data[0].candidates[0].personId];
              let confidence = identifyData.data[0].candidates[0].confidence;
              out += `${detectedPersonName} : ${confidence}. `;
              const infoMsg = 'Face identified: ' + out;
              console.log(infoMsg);
              firestoreObj.status = 'identified';
              firestoreObj.faceIdData = identifyData.data;
              db.collection('faceimages')
                .add(firestoreObj)
                .then((docref) => console.log('object stored in firebase: ' + docref.id));
              sendMail(detectedPersonName, createdAt, imageurl, confidence);
            }
          );
        } else {

          firestoreObj.status = 'detected';

          db.collection('faceimages')
            .add(firestoreObj)
            .then((docref) => console.log('object stored in firebase: ' + docref.id)); // 7Ew4ny2WFUzv2mjPNoOa
        }
        oncomplete(data);
      }).catch((reason) => { console.log(reason);});

  }
;

const Firestore = require('@google-cloud/firestore');

const firestore = new Firestore({
  projectId: 'entrancescreen',
  timestampsInSnapshots: true,
});

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const path = require('path');

exports.onnewimage = functions.storage.object().onFinalize(async (object) => {

  const filePath = object.name;

  const bucket = admin.storage().bucket(object.bucket);
  console.log(object);

  // Download file from bucket.
  bucket.file(filePath).getSignedUrl({
    action: 'read',
    expires: '01-01-2025'
  }).then((signedUrls) => {
    console.log(signedUrls);

    // Send it for detecting faces
    faceDetect(signedUrls[0],
      filePath,
      new Date(object.timeCreated),
      firestore,
      function (data) {
        console.log(`facedetect via Azure complete. Found ${data.data.length} faces`);
      });
  });
});
