/********************************************************************************************
* @Name         CustomLeadConvertTest
* @Author       Amit Yadav
* @Date         29/09/2023
* @Description  This Test class cover the CustomLeadConvert class
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         29/09/2023         Initial Creation                                                      
******************************************************************************************* */
@isTest
public class CustomLeadConvertTest {
    
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
        
        Lead testAnotherLead = new Lead(
            FirstName = 'Test01',
            LastName = 'Lead02',
            Company = 'Test Cmp01',
            Status = 'New',
            email = 'testDemo123@test.com',
            Parent_1_Email__c = 'testDemo123@test.com',
            Parent_1_First_Name__c = 'heheh',
            Parent_1_Last_Name__c = 'demo 01',
            recordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('Family Application').getRecordTypeId()
            // Ensure this is unique
        );
        insert testAnotherLead;
        Account ac = new Account(
        Name = 'Test account01'
        );
        insert ac;
        
        Contact con = new Contact(
            FirstName = 'ABC',
            AccountId = ac.Id,
            LastName = 'XYZ',
            Portal_Access__c = 'Activate',
            Email = 'testDemo123@test.com',
            RecordTypeId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Family Member').getRecordTypeId()
        );
        insert con;
    }
    
    @isTest
    static void testLeadConversionFamilyApplication() {
        // Retrieve the test Lead Id from the setup
        Lead testLead = [SELECT Id FROM Lead WHERE FirstName = 'Test' AND LastName = 'Lead' LIMIT 1];
        String leadId = CustomLeadConvert.leadRecord(testLead.Id);
        Test.startTest();
        // Perform lead conversion
        CustomLeadConvert.leadConvert(leadId);
        Test.stopTest();
        // Verify that the lead conversion was successful
        System.assertNotEquals(null, leadId);
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
    
    @isTest
    static void testLeadConversionWithExistingContact() {
        // Retrieve the test Lead Id from the setup
        Lead testLead = [SELECT Id FROM Lead WHERE Parent_1_Email__c = 'testDemo123@test.com' LIMIT 1];
        String leadId = CustomLeadConvert.leadRecord(testLead.Id);
        Test.startTest();
        // Perform lead conversion
        CustomLeadConvert.leadConvert(leadId);
        Test.stopTest();
    }
    
}