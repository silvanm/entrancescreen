import axios from 'axios';


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
function azureRequest(activity, params, data, method = 'post') {
  let subscriptionKey = 'c176a67cfe7b4617b144a0bf5414fe01';

  let uriBase =
    `https://entrancescreen.cognitiveservices.azure.com/face/v1.0/${activity}`;

  // Perform the REST API call.
  return axios({
    method: method,
    url: buildUrl(uriBase, params),
    headers: {
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Key': subscriptionKey
    },
    data: data
  });
}

function faceDetect(obj, db, oncomplete) {
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

  azureRequest('detect', params, {url: obj.url})
    .then((data) => {

      let firestoreObj = {
        filename: obj.filename,
        createdAt: obj.createdAt,
        sentAt: new Date(),
        detectData: data.data,
        status: 'detected'
      };

      // create new record in firebase
      db.collection('faceimages')
        .add(firestoreObj)
        .then(async (item) => {
          obj.firestoreObj = firestoreObj;
          obj.firestoreObj.id = item.id;
        }); // 7Ew4ny2WFUzv2mjPNoOa

      oncomplete(data);
    });

}

export { azureRequest, faceDetect };
