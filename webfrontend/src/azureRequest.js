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
function azureRequest(activity, params, data, method='post') {
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
  })
}

export default azureRequest;
