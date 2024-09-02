/********************************************************************************************
* @Name         PardotExternalActivityHttpCalloutMock
* @Author       Amit Yadav
* @Date         11/17/2023
* @Description  This mock test class is used to cover PardotExternalActivityPublisher   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         11/17/2023         Initial Creation                                                      
******************************************************************************************* */
@isTest
global class PardotExternalActivityHttpCalloutMock  implements HttpCalloutMock {
    public List<HTTPRequest> capturedRequests = new List<HTTPRequest>();

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        this.capturedRequests.add(req);
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(204);
        return res;
    }
}