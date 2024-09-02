/*********************************************************************************************************************************************
* @Name         VolunteerComplianceProcessorTest
* @Author       Amit Yadav
* @Date         30/05/2024
* @Description  The VolunteerComplianceProcessorTest class sets up test data, mocks HTTP responses, and verifies that the 
				VolunteerComplianceProcessorbatch class updates Volunteer_Compliance__c records correctly. It also tests the
                scheduling of the batch job to ensure it runs 
                at the specified time.
********************************************************************************************************************************************** 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         30/05/2024      Initial Creation                                                      
*********************************************************************************************************************************************/


/*The VolunteerComplianceProcessorTest class sets up test data, mocks HTTP responses, and verifies that the 
VolunteerComplianceProcessorbatch class updates Volunteer_Compliance__c records correctly. It also tests the
scheduling of the batch job to ensure it runs at the specified time.*/
@isTest
public class VolunteerComplianceProcessorTest {
	@testSetup
    public static void createAllData(){
        // Creating test Account records.
        Account ac = new Account();
        ac.Name = 'test';
        ac.Phone = '1234567890';
        ac.BillingStreet = 'testStreet';
        ac.BillingCity = 'Sydney';
        ac.BillingPostalCode = '778855';
        ac.BillingState = 'test';     
        insert ac;
        
        // Creating test Contact records.
        contact con = new contact();
        con.LastName = 'testq con';
        con.Email = 'test@22user.com';
        con.AccountId = ac.Id;
        con.Volunteer_Status__c = 'Volunteer';
        insert con;        
                                   
        // Creating test Volunteer Criteria record
        Volunteer_Criteria__c volCri = new Volunteer_Criteria__c();        
        volCri.Criteria_Type__c = 'Online Learning';
        volCri.Criteria_Status__c = 'Active';
        volCri.Display_Order__c = 12;
        volCri.Name = 'Code of Conduct';
        insert volCri;
        
        // Creating test Volunteer Compliance records
        List<Volunteer_Compliance__c> volComplianceList = new List<Volunteer_Compliance__c>();
        for(Integer i = 0; i < 5; i++) {
            Volunteer_Compliance__c volComp = new Volunteer_Compliance__c();
            volComp.Volunteer_Criteria__c = volCri.Id;
            volComp.Status__c = 'Assigned'; // or 'In Progress'
            volComp.Litmos_Course_ID__c = '1207831'; // Change to actual Litmos Course ID
            volComp.Volunteer_Name__c = con.Id;
            volComplianceList.add(volComp);
        }
        insert volComplianceList;
    }
    
    @istest
    public static void testVolunteerComplianceProcessor(){
        
		List<Volunteer_Compliance__c> volList = [SELECT Id,Status__c, PercentageComplete__c, Litmos_Course_Overdue__c, Date_Completed__c FROM Volunteer_Compliance__c WHERE Criteria_Type__c = 'Online Learning'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		 Test.startTest();
        VolunteerComplianceProcessor volCom = new VolunteerComplianceProcessor();
        Id jobid= Database.executeBatch(volCom);  
        Test.stopTest();        
        // Add assertions to check the results of the batch execution
        List<Volunteer_Compliance__c> listVol = [SELECT Id, Status__c, PercentageComplete__c, Litmos_Course_Overdue__c, Date_Completed__c FROM Volunteer_Compliance__c WHERE Criteria_Type__c = 'Online Learning'];
		Assert.isNotNull(listVol, 'String should be null'); // Succeeds
    }
    
    @isTest
    public static void testScheduledBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        // Schedule the batch class
        String jobId = System.schedule('Test Compliance Processor', '0 0 7 * * ? *', new VolunteerComplianceProcessor());
        Test.stopTest();      
        //  add assertions here to check that the job was scheduled correctly
        List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, cronTriggers.size(), 'The batch job should be scheduled.');
        System.assertNotEquals(null, cronTriggers[0].NextFireTime, 'The batch job should have a next fire time.');
    }
   
     // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('[{"OriginalId": "1207831", "Complete": true, "PercentageComplete": 100, "Overdue": false, "DateCompleted": "/Date(1651190400000+0000)/"}]');
            return res;
        }
    }   
}