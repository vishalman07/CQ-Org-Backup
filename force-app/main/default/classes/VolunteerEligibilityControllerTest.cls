/********************************************************************************************************************************
* @Name         VolunteerEligibilityControllerTest
* @Author       Amit Yadav
* @Date         22/05/2024
* @Description  VolunteerEligibilityControllerTest class contains test methods to validate 
                the behavior of methods in the VolunteerEligibilityController class. 
                It focuses on testing various functionalities and cover different senario.
********************************************************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         06/05/2024        Initial Creation                                                      
********************************************************************************************************************************/
@istest
public class VolunteerEligibilityControllerTest {
    
    public class MockHttpResponse implements HttpCalloutMock {
        // Implement this method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message":"This is a mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpResponseforError implements HttpCalloutMock {
        // Implement this method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message":"Please try after 1 or 2 minute"}');
            res.setStatusCode(429);
            return res;
        }
    }
	
    @testSetup
    public static void testData(){
        
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
        //Create Campaign 
        Campaign cam = new Campaign();
        cam.Name = 'Test Camp';
        cam.Cost_Centre__c = '1010';
        cam.Event_Type__c = 'Family Camp';
        cam.Event_Start_Date__c = System.today();
        cam.Event_End_Date__c = System.today() + 1;
        cam.IsActive = true;            
        insert cam;
        
        // Creating test Volunteer Attendence records.
        Volunteer_Attendance__c volAtt = new Volunteer_Attendance__c();
        volAtt.Participation_Role__c = 'Doctor';
        volAtt.Volunteer__c = con.Id;
        volAtt.Event__c = cam.Id;
        volAtt.Attendance__c = 'Invited';
        volAtt.Participation_Role__c = 'Doctor';
        insert volAtt;
        
        //Create Volunteer Creteria
		Volunteer_Criteria__c volCri = new Volunteer_Criteria__c();        
        volCri.Criteria_Type__c	 = 'Online Learning';
        volCri.Criteria_Status__c = 'Active';
        volCri.Display_Order__c = 12;
        volCri.Name = 'Code of Conduct';
        insert volCri;
        
        //Create Volunteer Complaince
        Volunteer_Compliance__c volComp  = new Volunteer_Compliance__c();
        volComp.Volunteer_Name__c = con.Id;
        volComp.Criteria_Type__c = 'Online Learning';
        volComp.Volunteer_Criteria__c = volCri.Id;
        volComp.PercentageComplete__c = 10;
        volComp.Litmos_Course_ID__c='1207831';
        volComp.Litmos_Course_Overdue__c = True;
        insert volComp;
    }
    
	@isTest
    public static void testgetContactDetails () {
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        Contact con = [Select Id,FirstName,LastName,Email,Volunteer_Status__c FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
        
        // Creating a test User associated with the retrieved Contact and CommunityProfile.
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            MobilePhone = '22463634',
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );
        insert us;
        String userIdToEncrypt = us.Id;
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        Test.startTest();
        String conStatus = VolunteerEligibilityController.getContactDetails(encryptedString);
        Test.stoptest();
		Assert.areEqual(con.Volunteer_Status__c,conStatus, 'samevalues'); // Succeeds
    }
    
    @isTest
    public static void testPositivegetCamEventDetail(){
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        Contact con = [Select Id,FirstName,LastName,Email,Volunteer_Status__c FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];        
        // Creating a test User associated with the retrieved Contact and CommunityProfile.
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            MobilePhone = '22463634',
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );
        insert us;
        String userIdToEncrypt = us.Id;
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        Test.startTest();
        VolunteerEligibilityController.getCamEventDetail(encryptedString);
        Test.stopTest();
    }
    
    @isTest
    public static void testNegativegetCamEventDetail(){
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        Contact con = [Select Id,FirstName,LastName,Email,Volunteer_Status__c FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
        
        // Creating a test User associated with the retrieved Contact and CommunityProfile.
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            MobilePhone = '22463634',
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );
        insert us;
        
 		// Create a Campaign for testing
        Campaign cam = new Campaign(
            Name = 'Test Campaign',
            Portal_Title__c = 'Test Event',
            RVSP__c = 'Yes',
            Event_Start_Date__c = DateTime.now(),
            Event_End_Date__c = DateTime.now().addDays(1),
            Registrations_Open__c = DateTime.now().addDays(-3),
            EndDate = Date.today().addDays(2),
            Event_Group__c = 'ACT'
        );
        insert cam;        
        List<VolunteerEligibilityController.EventWrapper> evetWrapList = new List<VolunteerEligibilityController.EventWrapper>();
        if (String.isNotBlank(cam.Portal_Title__c) && String.isNotBlank(cam.RVSP__c)){
         VolunteerEligibilityController.EventWrapper  eventWrap= new VolunteerEligibilityController.EventWrapper();
            eventWrap.eventTitle = cam.Portal_Title__c;
            Date formatDate = Date.valueOf(cam.Event_Start_Date__c);
            List<String> dateList = String.valueOf(formatDate).split('-');
            eventWrap.eventDate = cam.Event_Start_Date__c.day().toString()+'-'+cam.Event_Start_Date__c.month().toString()+'-'+cam.Event_Start_Date__c.year().toString();
            eventWrap.eventId = cam.Id; 
            evetWrapList.add(eventWrap);
        }        
        String userIdToEncrypt = us.Id;
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        Test.startTest();
        VolunteerEligibilityController.getCamEventDetail(encryptedString);
        Test.stopTest();
    }
    
    @isTest
    public static void testcomplainceLearning(){
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        Contact con = [Select Id,FirstName,LastName,Email,Volunteer_Status__c FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
        
        // Creating a test User associated with the retrieved Contact and CommunityProfile.
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            MobilePhone = '22463634',
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );
        insert us;
        String userIdToEncrypt = us.Id;
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        VolunteerEligibilityController.complainceLearning(encryptedString);
    }
    
    @isTest
    public static void testDecryptedData() {
        // Test data        
        String userIdToEncrypt = UserInfo.getUserId() ;
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        
        //String userIdToEncrypt = UserInfo.getUserId() ;
        Blob keyde = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherTextde = Crypto.decryptWithManagedIV('AES128', keyde, cipherText);
        String encryptedString2 = EncodingUtil.base64Encode(cipherText);
        	
        // Call the method to test
        String decryptedString = CommunityLoginController.decryptedData(encryptedString2);
        
        // Verify the result
        System.assertEquals(userIdToEncrypt, decryptedString, 'Decryption failed');
    }
    
    @isTest
    public static void testUpdateCon(){
		String litMosres = '123456789';
        Contact con = [Select Id,FirstName,LastName,Email,Volunteer_Status__c FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
        Test.startTest();
        VolunteerEligibilityController.updateCon(con.Id, litMosres);
        Test.stopTest();
           // Step 3: Verify the contact record was updated
        Contact updatedContact = [SELECT Id, Litmos_Account_ID__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals(litMosres, updatedContact.Litmos_Account_ID__c);
    }
    
    @istest
    public static void testLitMosCallout(){
         Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        Contact con = [Select Id,FirstName,LastName,Email,Volunteer_Status__c FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
        
        // Creating a test User associated with the retrieved Contact and CommunityProfile.
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            MobilePhone = '22463634',
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );
        insert us;
        String userIdToEncrypt = us.Id;
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
	
        Test.setMock(HttpCalloutMock.class, new LitMosCalloutMock());

        // Step 3: Call the method
        Test.startTest();
        String loginKey = VolunteerEligibilityController.litMosCallout(encryptedString);
        Test.stopTest();

        // Step 4: Verify the results
        System.assertNotEquals(null, loginKey, 'LoginKey should not be null');
        
        // Verify the Contact record has been updated
        Contact updatedContact = [SELECT Litmos_Account_ID__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals('mockLitmosId', updatedContact.Litmos_Account_ID__c);
    }
    
    // Mock class for the callouts
    private class LitMosCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if(req.getEndpoint().contains('search')) {
                // Mocking the search response
                res.setBody('[{"Id": "mockLitmosId", "Email": "test@example.com"}]');
            } else {
                // Mocking the user detail response
                res.setBody('{"Id": "mockLitmosId", "LoginKey": "mockLoginKey"}');
            }
            
            res.setStatusCode(200);
            return res;
        }
    }
    

    
    @isTest
    public static void testLitMosCalloutforRefresh() {
     	 Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        Contact con = [Select Id,FirstName,LastName,Email,Volunteer_Status__c FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
        
        // Creating a test User associated with the retrieved Contact and CommunityProfile.
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            MobilePhone = '22463634',
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );
        insert us;
        
        
        List<Volunteer_Compliance__c> volComList = [
            SELECT Id, Volunteer_Criteria__r.Name, Status__c, Volunteer_Criteria__r.Display_Order__c, Litmos_Course_ID__c, Criteria_Type__c, Volunteer_Name__c, PercentageComplete__c 
            FROM Volunteer_Compliance__c
            WHERE Criteria_Type__c = 'Online Learning' AND Volunteer_Name__c =:con.Id];

        String userIdToEncrypt = us.Id;
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        Test.setMock(HttpCalloutMock.class, new LitMosCalloutforRefreshMock());
        Test.startTest();
        List<Volunteer_Compliance__c> result = VolunteerEligibilityController.litMosCalloutforRefresh(encryptedString);
        Test.stopTest();
        Assert.areEqual(1, result.size(), 'Result size should be 1');
        Volunteer_Compliance__c updatedVolCom = result[0];
       Assert.areEqual('Active', updatedVolCom.Status__c, 'Status should be Active');
        Assert.areEqual(100, updatedVolCom.PercentageComplete__c, 'PercentageComplete should be 100');
    }

    

    public class LitMosCalloutforRefreshMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('[{"OriginalId": "1207831", "Complete": true, "PercentageComplete": 100, "Overdue": false, "DateCompleted": "/Date(1651190400000+0000)/"}]');
            res.setStatusCode(200);
            return res;
        }
    }

	@isTest
    static void testUploadFile_Success() {
        // Step 1: Prepare test data
        Volunteer_Compliance__c volCom = [SELECT Id FROM Volunteer_Compliance__c WHERE Criteria_Type__c = 'Online Learning' LIMIT 1];
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String filename = 'Test_File.txt';
        String recordId = volCom.Id; 

        // Step 2: Call the method
        Test.startTest();
        String contentDocumentLinkId = VolunteerEligibilityController.uploadFile(base64, filename, recordId);
        Test.stopTest();

        // Step 3: Verify the result
        System.assertNotEquals(null, contentDocumentLinkId, 'ContentDocumentLink should not be null');
    }
    
        @isTest
    static void testCreateContentVersion_Success() {
        // Step 1: Prepare test data
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String filename = 'Test_File.txt';

        // Step 2: Call the method
        Test.startTest();
        ContentVersion cv = VolunteerEligibilityController.createContentVersion(base64, filename);
        Test.stopTest();

        // Step 3: Verify the result
        System.assertNotEquals(null, cv, 'ContentVersion should not be null');
    }
    
    
        @isTest
    static void negatestCreateContentVersion_Success() {
        // Step 1: Prepare test data
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test File '));
        String filename = 'Test_File.txt';

        // Step 2: Call the method
        Test.startTest();
        ContentVersion cv = VolunteerEligibilityController.createContentVersion(base64, filename);
        Test.stopTest();

        // Step 3: Verify the result
        System.assertNotEquals(null, cv, 'ContentVersion should not be null');
    }

      @isTest
    static void testLitMosCalloutMethod() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseforError());
     
        // Call the method with a sample URL
        String baseUrl = 'https://api.example.com/mockendpoint';
        String response = VolunteerEligibilityController.litMosCalloutmetod(baseUrl);
        
        String baseUrl2 = 'https://api.example.com/mockendpoint';
        String response2 = VolunteerEligibilityController.litMosCalloutmetod(baseUrl2);
        
        // Assert the response
        System.assertNotEquals('{"message":"This is a mock response"}', response);
    }
}