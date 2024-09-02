/********************************************************************************************
* @Name         PardotExternalActivityPublisherTest
* @Author       Amit Yadav
* @Date         11/17/2023
* @Description  This test class is used to cover PardotExternalActivityPublisher   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         11/17/2023         Initial Creation                                                      
******************************************************************************************* */
@isTest
private class PardotExternalActivityPublisherTest {
    
    @isTest
    static void shouldMakeHttpCallout() {
        //arrange
        List<PardotExternalActivityPublisher.ExternalActivity> activities = new List<PardotExternalActivityPublisher.ExternalActivity>();

        //Build out requests to fill a single batch
        for(Integer i = 0; i<PardotExternalActivityPublisher.HTTP_REQUESTS_PER_BATCH; i++) {
            activities.add(buildActivity('bob'+i+'@email.com'));
        }

        PardotExternalActivityHttpCalloutMock httpMock = new PardotExternalActivityHttpCalloutMock();

        //act
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, httpMock);
            PardotExternalActivityPublisher.sendActivityToPardot(activities);
        Test.stopTest();

        //assert
        for(Integer i=0; i<PardotExternalActivityPublisher.HTTP_REQUESTS_PER_BATCH; i++) { //we are testing that all callouts for a single batch are made
            HttpRequest result = httpMock.capturedRequests.get(i);
            String bodyJson = result.getBody();
            PardotExternalActivityPublisher.ExternalActivity activity = (PardotExternalActivityPublisher.ExternalActivity) System.JSON.deserialize(bodyJson, PardotExternalActivityPublisher.ExternalActivity.class);
            System.assertEquals('bob'+i+'@email.com', activity.email);
            System.assertEquals('Zoom', activity.extension);
            System.assertEquals('Registered', activity.type);
            System.assertEquals('832763562363', activity.value);
        }
    }

    private static PardotExternalActivityPublisher.ExternalActivity buildActivity(String email) {
        PardotExternalActivityPublisher.ExternalActivity a = new PardotExternalActivityPublisher.ExternalActivity();
        a.email = email;
        a.extension='Zoom';
        a.type='Registered';
        a.value='832763562363';
        return a;
    }
}