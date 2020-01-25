Deploy
======

    gcloud functions deploy onnewimage --runtime nodejs10 --trigger-bucket gs://entrancescreen.appspot.com

Test 
====

Shell 1: Start test server 

    npm start
    
Shell 2: Issue a message

    curl -d "@message.json" \
           -X POST \
           -H "Ce-Type: true" \
           -H "Ce-Specversion: true" \
           -H "Ce-Source: true" \
           -H "Ce-Id: true" \
           -H "Content-Type: application/json" \
           http://localhost:8080
