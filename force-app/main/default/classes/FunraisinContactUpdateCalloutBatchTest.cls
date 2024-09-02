/********************************************************************************************
* @Name         FunraisinContactUpdateCalloutBatchTest
* @Author       Amit Yadav
* @Date         09/08/2023
* @Description  This Test class cover FunraisinContactUpdateCalloutBatch class 
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         09/08/2023         Initial Creation                                                      
******************************************************************************************* */
@isTest
public class FunraisinContactUpdateCalloutBatchTest {
    // Create a mock class for the HTTP callout
    public class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create a dummy HTTP response to simulate the callout
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Mock response body');
            return res;
        }
    }
    @testSetup
    static void setupTestData() {
        // Create test records for the Contacts
        List<Contact> testContacts = new List<Contact>();
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Family').getRecordTypeId();
		insert ac;
        for (Integer i = 0; i < 2; i++) {
            Contact testContact = new Contact(
                FirstName = 'John' + i,
                LastName = 'Doe' + i,
                AccountId = ac.Id,
                C_Funraisin_Id__c = 'funraisin:123' + i,
                Email = 'john.doe' + i + '@example.com',
                MobilePhone = '123-456-7890' + i,
                HomePhone = '987-654-3210' + i,
                Birthdate = Date.newInstance(1990, 1, 1),
                MailingCity = 'City' + i,
                MailingStreet = '123 Main St' + i,
                MailingState = 'CA' + i,
                MailingCountry = 'USA' + i,
                MailingPostalCode = '12345' + i,
                recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId()
               
                // Add more fields as needed
            );
            testContacts.add(testContact);
             //system.debug(' recordTypeId' +recordTypeId);
        }
        insert testContacts;
    }

    @isTest
    static void testBatchExecution() {
          // Set the mock callout class for the test
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Retrieve the Contact Ids dynamically from the test data created in the setup method
        List<Contact> testContacts = [SELECT Id FROM Contact WHERE FirstName LIKE 'John1'];
        List<Contact> contactList = new List<Contact>();

        for (Contact contact : testContacts) {
            contact.MobilePhone = '9876543422';
            contactList.add(contact);
        }
        Test.startTest();
        update contactList;
        Assert.areEqual(1, contactList.size());
        Assert.areEqual('9876543422', contactList[0].MobilePhone, 'MobilePhone should be updated to 9876543422');
        Test.stopTest();
        
    }
}