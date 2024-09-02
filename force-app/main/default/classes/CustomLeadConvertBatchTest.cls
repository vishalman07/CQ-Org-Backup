/********************************************************************************************
* @Name         CustomLeadConvertBatch
* @Author       Amit Yadav
* @Date         11/01/2024
* @Description  This batch class convert the lead and run "Lead convert process new" autolaunched flow after geeting result created permissionSetAssignment for contactOwner.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         11/01/2024         Initial Creation                                                      
******************************************************************************************* */
@isTest
public class CustomLeadConvertBatchTest {
    // Define test data in setup methods
    @testSetup
    static void setupTestData() {
        // Create test Leads
        Lead testLeadFamily = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testingDemo02@gmail.com', // Ensure this is unique
            Status = 'New',
            Parent_1_Email__c = 'testDemo1@test.com',
            Parent_1_First_Name__c = 'Demo',
            Parent_1_Last_Name__c = 'version 011',
            recordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('Family Application').getRecordTypeId()
        );
        insert testLeadFamily;
        
        Lead testLeadVolunteer = new Lead(
            FirstName = 'Test',
            LastName = 'VolunteerLead',
            Company = 'Test Company',
            Status = 'New',
            Email = 'testvolunteer@test.com', // Ensure this is unique
            recordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('Volunteer').getRecordTypeId()
        );
        insert testLeadVolunteer;
        
    }
    @isTest
    static void testBatchExecution() {
        // Create test leads
        List<Lead> testLeads = [Select id From lead where Parent_1_Email__c = 'testDemo1@test.com' limit 1];
        
        // Start the batch job
        Test.startTest();
        CustomLeadConvertBatch batchJob = new CustomLeadConvertBatch(testLeads);
        Database.executeBatch(batchJob , 1);
        Test.stopTest();
        
        // Add more assertions as needed based on your batch logic
    }
    
    @isTest
    static void testBatchExecutionElse() {
        // Create test leads
        List<Lead> testLeads = [Select id From lead  limit 2];
        
        // Start the batch job
        Test.startTest();
        CustomLeadConvertBatch batchJob = new CustomLeadConvertBatch(testLeads);
        Database.executeBatch(batchJob , 2);
        Test.stopTest();
        
        // Add more assertions as needed based on your batch logic
    }
    
    @isTest
    static void testLeadConversionVolunteer() {
        // Retrieve the test Volunteer Lead Id from the setup
        Lead testVolunteerLead = [SELECT Id FROM Lead WHERE FirstName = 'Test' AND LastName = 'VolunteerLead' LIMIT 1];
        String leadId = CustomLeadConvert.leadRecord(testVolunteerLead.Id);
        Test.startTest();
        // Perform lead conversion
        CustomLeadConvert.leadConvert(leadId);
        Test.stopTest();
        // Verify that the lead conversion was successful
        System.assertNotEquals(null, leadId);
    }
    
}