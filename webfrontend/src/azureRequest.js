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
  let subscriptionKey = process.env.VUE_APP_AZURE_KEY;

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
      oncomplete(data);
    });

}

export { azureRequest, faceDetect };
