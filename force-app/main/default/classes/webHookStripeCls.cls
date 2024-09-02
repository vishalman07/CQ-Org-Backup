@RestResource(urlMapping='/mystripeWebhook/*')
global class webHookStripeCls {
    @HttpPost 
    global static void doPost(){
        system.debug('Class called ==>>');
        /*RestResponse res = RestContext.response;
        res.addHeader('Content-type','application/json');
        string response  = RestContext.request.requestBody.toString();
        System.debug('-=-=-=>>>>>>'+ response);*/
        
        
       /* RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody.toString();
        system.debug('requestBody====>'+requestBody); */
        // Parse the incoming JSON request body
       /* Map<String, Object> webhookPayload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        try {
            // Process the webhook based on its type
         //   processWebhook(webhookPayload);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Success');
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        } */
    }
}