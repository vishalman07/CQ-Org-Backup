/********************************************************************************************
* @Name         JotFormQuestionUpdateSchedulerTest
* @Author       Navneet Sharma
* @Date         12/7/2023
* @Description  This class is used to test JotFormQuestionUpdateScheduler   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0            Navneet Sharma    12/07/2023         Initial Creation                                                      
******************************************************************************************* */
@isTest(SeeAllData=True)
private class JotFormQuestionUpdateSchedulerTest {

    @isTest
    static void testExecute() {
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create an instance of the scheduler
        JotFormQuestionUpdateScheduler scheduler = new JotFormQuestionUpdateScheduler();

        // Call the execute method
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

    }

    // Mock class for HTTP callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Mock the response here
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }


}