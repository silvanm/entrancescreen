/* eslint no-console: 0 */

const axios = require('axios');

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
  let subscriptionKey = 'c176a67cfe7b4617b144a0bf5414fe01';

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

const faceDetect = function (binaryData, filename, createdAt, db, oncomplete) {
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

  azureRequest('detect', params, binaryData, 'post', 'application/octet-stream')
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
        azureRequest('identify',
          [], {
            'faceIds': [data.data[0].faceId],
            'personGroupId': 'muehlemann'
          }).then((identifyData) => {
          let out = '';
          identifyData.data[0].candidates.forEach((o) => {
            out += `${o.personId}: ${o.confidence}. `;
          });
          console.log('Face identified: ' + out);
          firestoreObj.status = 'identified';
          firestoreObj.faceIdData = identifyData.data;
          db.collection('faceimages')
            .add(firestoreObj)
            .then((docref) => console.log('object stored in firebase: ' + docref.id));
        });
      } else {

        firestoreObj.status = 'detected';

        db.collection('faceimages')
          .add(firestoreObj)
          .then((docref) => console.log('object stored in firebase: ' + docref.id)); // 7Ew4ny2WFUzv2mjPNoOa
      }
      oncomplete(data);
    }).catch((reason) => { console.log(reason);});

};

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
  bucket.file(filePath).download((err, contents) => {
    console.log('Bytes downloaded: ', contents.length);

    // Send it for detecting faces
    faceDetect(contents,
      filePath,
      new Date(object.timeCreated),
      firestore,
      function (data) {
        console.log(`facedetect via Azure complete. Found ${data.data.length} faces`);
      });
  });
});
