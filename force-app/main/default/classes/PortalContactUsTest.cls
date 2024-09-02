/********************************************************************************************
* @Name         PortalContactUsTest
* @Author       Amit Yadav
* @Date         10/01/2024
* @Description  This class cover code of PortalContactUs apex class.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         10/01/2024         Initial Creation                                                      
******************************************************************************************* */
@isTest
private class PortalContactUsTest {
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
        Contact con = new Contact();
        con.AccountId = ac.Id;
        con.LastName = 'Test';
        con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Volunteer').getRecordTypeId();
        con.Email = 'test@gmail.com';
        con.HomePhone = '12345678';
        con.Preferred_Event_Locations__c = 'Central Queensland';
        con.MailingCity = 'Delhi';
        con.MailingStreet = 'testConStreet';
        con.MailingState = 'UP';
        con.MailingPostalCode = '443322';
        con.MailingCountry = 'UK';
        con.Swimming_Ability__c = '25-50m';
        con.Shirt_Size__c = 'Adult XS';
        con.Emergency_Contact__c = '5554449991';
        con.Emergency_Contact_Phone__c = '1239870458';
        con.Emergency_Contact_Mobile__c = '9807654321';
        con.Emergency_Contact_Relationship__c = 'Test';
        con.Birthdate = System.today();
        con.MobilePhone = '7856412534';
        con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Volunteer').getRecordTypeId();
        insert con;
    }
    @isTest
    static void testCreateCase(){
                // Retrieving a Contact created in the test data setup.
        Contact con = [Select Id,FirstName,LastName,Email FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
                // Creating a test User associated with the retrieved Contact and CommunityProfile.
         	    // Retrieving the CommunityProfile profile.
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            Phone = '22463634',
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );
         // Running as the test User to execute the methods in CommunityLoginController. 
        System.runAs(us){
                   // Call the createCase method from the PortalContactUs class
        String result = PortalContactUs.createCase('testsubject', 'details', 'Complex functionality', us.Id);
        String result2 = PortalContactUs.createCaseforFamily('subject', 'details', 'reason', us.Id);


        // Add assertions to verify the expected behavior
        System.assertNotEquals(null, result);
        System.assertEquals('Your message has been received. Someone will contact you shortly.', result);

        }
    }
    @isTest
    static void testCreateLoginCase() {
        // Set up the test data for the login case creation
        String subject = 'Test Subject';
        String details = 'Test Details';
        String reason = 'Test Reason';
        
        Contact con = [Select Id,FirstName,LastName,Email FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
                // Creating a test User associated with the retrieved Contact and CommunityProfile.
         	    // Retrieving the CommunityProfile profile.
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            Phone = '22463634',
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );

        // Call the createLoginCase method from the PortalContactUs class
        String result = PortalContactUs.createLoginCase(subject, details, reason);
        
        // Add assertions to verify the expected behavior
        System.assertNotEquals(null, result);
        System.assertEquals('Your message has been received. Someone will contact you shortly.', result);

        // Additional assertions if needed
        Case[] createdCases = [SELECT Id FROM Case];
        System.assertEquals(1, createdCases.size(), 'Expected one case to be created');
    }
}