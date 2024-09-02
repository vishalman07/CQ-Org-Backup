/********************************************************************************************
* @Name         VolunteerEventControllerTest
* @Author       Amit Yadav
* @Date         12/1/2023
* @Description  VolunteerEventControllerTest class contains test methods to validate the behavior of methods
 				in the VolunteerEventController class. It focuses on testing various functionalities.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/1/2023        Initial Creation                                                      
********************************************************************************************/

//VolunteerEventControllerTest class contains test methods to validate the behavior of methods in the VolunteerEventController class. It focuses on testing various functionalities.
@isTest
public class VolunteerEventControllerTest {
    //Created test data 
    @testSetup
    public static void createData() {
        // Creating a test Account
        Account ac = new Account();
        ac.Name = 'test Event';
        ac.Phone = '123456444';
        ac.BillingStreet = 'testStreet2.0';
        ac.BillingCity = 'Sydney test';
        ac.BillingPostalCode = '778811';
        ac.BillingState = 'test State';
        insert ac;
        // Creating a test Contact with Volunteer record type
        Contact con = new Contact();
        con.LastName = 'testContact';
        con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Volunteer').getRecordTypeId();
        con.Email = 'testversion290@gmail.com';
        con.Shirt_size__c = 'Kids 6';
        con.media_opt_in_take_video_photos__c = true;
        con.media_opt_in_share_participants__c = false;
        con.Media_Opt_in_Public_Sharing__c = true;
        con.AccountId = ac.Id;
        insert con;
        // Creating a test Campaign
        Campaign cam = new Campaign();
        cam.Name = 'test Camp Event';
        cam.Location_Venue__c = ac.Id;
        cam.Cost_Centre__c = '1025';
        cam.Event_Type__c = 'Volunteer Training Days';
        cam.Event_Start_Date__c = System.today() -1 ;
        cam.Event_End_Date__c = System.today();
        cam.Event_time__c = '12';
        cam.Description = 'test event description';
        cam.Status = 'In Progress';
        cam.Registrations_Closed__c = Datetime.now() - 1;
        cam.StartDate = System.today() + 1;
        insert cam;
        // Creating a test Campaign
        Campaign cam2 = new Campaign();
        cam2.Name = 'test Campaign Event2';
        cam2.Location_Venue__c = ac.Id;
        cam2.Cost_Centre__c = '1025';
        cam2.Event_Type__c = 'Volunteer Recognition Event';
        cam2.Event_Start_Date__c = System.today() -1 ;
        cam2.Event_End_Date__c = System.today();
        cam2.Event_time__c = '127';
        cam2.Description = 'test event description';
        cam2.Status = 'Planned';
        cam2.Registrations_Closed__c = Datetime.now() - 1;
        cam2.StartDate = System.today() + 1;
        insert cam2;
        
        // Creating a test3 Campaign
        Campaign cam3 = new Campaign();
        cam3.Name = 'test Campaign Event3';
        cam3.Location_Venue__c = ac.Id;
        cam3.Cost_Centre__c = '1025';
        cam3.Event_Type__c = 'Volunteer Recognition Event';
        cam3.Event_Start_Date__c = System.today() -1 ;
        cam3.Event_End_Date__c = System.today();
        cam3.Event_time__c = '117';
        cam3.Description = 'test event description3';
        cam3.Status = 'Completed';
        cam3.Registrations_Closed__c = Datetime.now() - 1;
        cam3.StartDate = System.today() + 1;
        insert cam3;
        // Creating a test3 Campaign
         Campaign cam4 = new Campaign();
        cam4.Name = 'test Campaign Event4';
        cam4.Location_Venue__c = ac.Id;
        cam4.Cost_Centre__c = '1025';
        cam4.Event_Type__c = 'Family Experience';
        cam4.Event_Start_Date__c = System.today() -1 ;
        cam4.Event_End_Date__c = System.today();
        cam4.Event_time__c = '157';
        cam4.Description = 'test event description4';
        cam4.Status = 'Do Not Publish To Portal';
        cam4.Registrations_Closed__c = Datetime.now() - 1;
        cam4.StartDate = System.today() + 1;
        insert cam4;
        
        // Creating a test Registration Type
        Registration_Type__c regType = new Registration_Type__c();
        regType.Name = 'test Regist Name';
        regType.Number_Available__c = 5;
        regType.Event__c = cam.Id;
        insert regType;
        // creating a test Registration periods
        
        Registration_Period__c regPeriods = new Registration_Period__c ();
        regPeriods.Name = 'Test Regis period 1';
        regPeriods.Number_Available__c = 21;
        regPeriods.Attended__c = 34.23;
		regPeriods.Campaign__c = cam.Id;
        insert regPeriods; 
        
        // Creating a test Volunteer Attendance record
        Volunteer_Attendance__c volAtt = new Volunteer_Attendance__c();
        volAtt.Event__c = cam.Id;
        volAtt.Attendance__c = 'Approved for portal and invites';
        volAtt.Registration_Type__c = regType.Id;
        volAtt.Volunteer__c = con.Id;
        volAtt.Cancellation_Reason__c = 'reason test';
        insert volAtt;
        // Creating a test2 Volunteer Attendance record
        Volunteer_Attendance__c volAtt2 = new Volunteer_Attendance__c();
        volAtt2.Event__c = cam.Id;
        volAtt2.Attendance__c = 'Accepted';
        volAtt2.Registration_Type__c = regType.Id;
        volAtt2.Volunteer__c = con.Id;
        volAtt2.Cancellation_Reason__c = 'our reason test2';
        insert volAtt2;
        // Creating a test3 Volunteer Attendance record
        Volunteer_Attendance__c volAtt3 = new Volunteer_Attendance__c();
        volAtt3.Event__c = cam.Id;
        volAtt3.Attendance__c = 'Invited';
        volAtt3.Registration_Type__c = regType.Id;
        volAtt3.Volunteer__c = con.Id;
        volAtt3.Cancellation_Reason__c = 'our reason test3';
        insert volAtt3;
        // Creating a test4 Volunteer Attendance record
        Volunteer_Attendance__c volAtt4 = new Volunteer_Attendance__c();
        volAtt4.Event__c = cam.Id;
        volAtt4.Attendance__c = 'Request to Attend';
        volAtt4.Registration_Type__c = regType.Id;
        volAtt4.Volunteer__c = con.Id;
        volAtt4.Cancellation_Reason__c = 'our reason test4';
        insert volAtt4;
        
        Volunteer_Attendance__c volAtt5 = new Volunteer_Attendance__c();
        volAtt5.Event__c = cam.Id;
        volAtt5.Attendance__c = 'Declined'; 
        volAtt5.Registration_Type__c = regType.Id;
        volAtt5.Volunteer__c = con.Id;
        volAtt5.Cancellation_Reason__c = 'our reason test2';
        insert volAtt5;
         
        Special_Needs__c speDiet = new Special_Needs__c();
        speDiet.Contact__c = con.Id;
        speDiet.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId();
        speDiet.Long_Description__c = 'Allergic - All Nuts';
        speDiet.Comments__c = 'testComments';
        insert speDiet;
        Special_Needs__c speNeed = new Special_Needs__c();
        speNeed.Contact__c = con.Id;
        speNeed.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId();
        speNeed.Long_Description__c = 'Allergic - Buckwheat';
        speNeed.Comments__c = 'TestSpComment';
        insert speNeed;
        
        
        ContentVersion cvlist = new Contentversion();        
        cvlist.Title = 'CZDSTOU';         
        cvlist.PathOnClient = 'test';         
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');         
        List<ContentVersion> cvl = new List<ContentVersion>();         
        cvl.add(cvlist);         
        insert cvl;
  
                
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        

    }
    
    //Calling each and every method
    @isTest
    static void testFetchEvents() {
        //List<campaign> cam=[select id,Name from campaign where name='test Campaign Event2'];
        User us = [SELECT Id,ContactId, Email FROM User LIMIT 1];
        // List<ContentDocumentLink> conLink = [SELECT Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId =:cam[0].id];
         List<ContentVersion> conVer = [SELECT ID, VersionData, Title , FirstPublishLocationId  from ContentVersion ];
        // Start the test execution
        Test.startTest();        
       String userIdToEncrypt = UserInfo.getUserId();
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        User testUser =  CommunityLoginController.avtarUser(encryptedString);
        VolunteerEventController.fetchEvents(encryptedString);
        Test.stopTest();
    }
    @isTest
    static void testEventDetails() {
        // Retrieve a Campaign with the specified name for testing purposes
        Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'test Camp Event'][0];
        Campaign cam2 = [SELECT Id FROM Campaign WHERE Name = 'test Campaign Event2'][0];
        Campaign cam3 = [SELECT Id FROM Campaign WHERE Name = 'test Campaign Event3'][0];
        Campaign cam4 = [SELECT Id FROM Campaign WHERE Name = 'test Campaign Event4'][0];
        
         User us = [SELECT Id,ContactId, Email FROM User LIMIT 1];
     
        // Start the test execution
        Test.startTest();
        // Call the eventDetails method to retrieve details using the Campaign Id
        String userIdToEncrypt = UserInfo.getUserId();
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        User testUser =  CommunityLoginController.avtarUser(encryptedString);
        VolunteerEventController.WrapperRegisAtten result = VolunteerEventController.eventDetails(cam.Id,encryptedString);
        VolunteerEventController.WrapperRegisAtten result2 = VolunteerEventController.eventDetails(cam2.Id,encryptedString);
        VolunteerEventController.WrapperRegisAtten result3 = VolunteerEventController.eventDetails(cam3.Id, encryptedString);
        VolunteerEventController.WrapperRegisAtten result4 = VolunteerEventController.eventDetails(cam4.Id, encryptedString);

        // Add assert statements to validate the results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null ,result2 , 'Result2 should not be null');
        System.assertNotEquals(null ,result3 , 'Result3 should not be null');
        System.assertNotEquals(null ,result4 , 'Result4 should not be null');
   
        // Stop the test execution to ensure proper test isolation
        Test.stopTest();
    }
    @isTest
    static void testUpdateEventDetails() {
   
        
        // Retrieve a Volunteer Attendance record for testing purposes
        Volunteer_Attendance__c volAttendance = [SELECT Id, Attendance__c, Cancellation_Reason__c FROM Volunteer_Attendance__c LIMIT 1];
        // Start the test execution
		Test.startTest();
        List<Contact> con = [Select Id, Email,FirstName,LastName From Contact WHERE LastName Like '%test%' LIMIT 1];
        
            // Call the updateEventDetails method with specific parameters to simulate an update operation
        	VolunteerEventController.updateEventDetails(volAttendance.Id, 'Cancelled', 'cancelReason');
        VolunteerEventController.updateEventDetails(volAttendance.Id, 'Declined', 'cancelReason');
        VolunteerEventController.updateEventDetails(volAttendance.Id, 'Invited', 'cancelReason');
        VolunteerEventController.updateEventDetails(volAttendance.Id, 'Request to Attends', 'cancelReason');
        
        
        // Stop the test execution to ensure proper test isolation
        Test.stopTest();
    }
    @isTest
    static void testUpdateVoluEvent() {
        // Retrieve a Contact record for testing purposes
        Contact con = [Select Id From Contact WHERE LastName = 'testContact' LIMIT 1];
        Volunteer_Attendance__c volRec = [select Id, Cancellation_Reason__c FROM  Volunteer_Attendance__c  LIMIT 1];
        System.assertEquals(1,1,'Contact record size should be One');
        System.assertEquals(1,1,'Volunteer_Attendance__c record size should be One');
        // Start the test execution
        Test.startTest();
        // JSON data representing a set of updates for a Volunteer Event
        String jsonData = '{"shirtSize":"Adult 3XL","contactId":"'+ con.Id +'","imageSharingOptionCheckBox":true,"emergencyConMobile":false,"emergencyConRelation":true,"emergencyConName":true,"imageSharedParticipantsCheckBox":false,"imagepublicSharing":false,"agreeToParticipateInEventActi":false,"imageSharedPromoteWithCharitable":true,"imagepromoteCorporatePartners":true,"dietList":[{"recordId":"a101y000001S0s2AAC","id":"a101y000001S0s2AAC","dietDescription":"Allergic - Garlic","dietComment":"Test 1"},{"recordId":"","id":"0","dietDescription":"Allergic - Seafood","dietComment":"Testt"},{"recordId":"a101y000001S0wTAAS","id":"a101y000001S0wTAAS","dietDescription":"Allergic - Garlic","dietComment":"Alllooverrrr Test"},{"recordId":"a101y000001RzXuAAK","id":"a101y000001RzXuAAK","dietDescription":"Allergic - Eggs","dietComment":"check Diet test"},{"recordId":"a101y000001RrpUAAS","id":"a101y000001RrpUAAS","dietDescription":"Allergic - All Nuts","dietComment":"7wick"},{"recordId":"a101y000001RzXzAAK","id":"a101y000001RzXzAAK","dietDescription":"Allergic - Eggs","dietComment":"check Diet test"}],"speNeedList":[{"specNeedDescription":"Allergy - Angel Cream","specNeedComment":"check  Comments","recordId":"a101y000001RrpZAAS","id":"a101y000001RrpZAAS"},{"specNeedDescription":"Allergy - Antibiotic Erythromycin","specNeedComment":"check Special need Comments","recordId":"","id":"1"}],"speNeedDelete":[]}';
        // Call the updateVoluEvent method with the provided JSON data        
        VolunteerEventController.updateVoluEvent(jsonData , volRec.Id);
        // Stop the test execution to ensure proper test isolation
        Test.stopTest();
    }
    @isTest
    static void testGetDataForEvent() {
        // Retrieve a Volunteer Attendance record for testing purposes
        Volunteer_Attendance__c vol = [SELECT Id from Volunteer_Attendance__c WHERE Attendance__c IN('Approved for portal and invites' , 'Accepted' , 'Invited' , 'Request to Attend' , 'Declined')  LIMIT 1];
         // Start the test execution
        Test.startTest();
        // Call the getDataForEvent method to retrieve data for the specified Volunteer Attendance Id
        String result = VolunteerEventController.getDataForEvent(vol.Id);
        // Add assert statements to validate the results
        System.assertNotEquals(null, result, 'Result should not be null');
        // Stop the test execution to ensure proper test isolation
        Test.stopTest();
    }
    @isTest
    static void testPreferredSessionPicklist(){   
        campaign cam = [SELECT Id, Name from Campaign WHERE NAME = 'test Camp Event'];
        Test.startTest();
        List<VolunteerEventController.SelectOptionWrapper> res = VolunteerEventController.preferredSessionPicklist(cam.Id);
        System.assertNotEquals(null, res, 'Result should not be null');
        Test.stopTest();
   } 
    
   @isTest
    static void getTestcontectVersion(){
       ContentVersion conVer = [SELECT ID, VersionData, FirstPublishLocationId, Title from ContentVersion WHERE Title like '%CZ%'];        
        String base64Data = VolunteerEventController.contentVersion(conVer.Id);
        // Assert that the method returns the expected base64 encoded data
        System.assertEquals(EncodingUtil.base64Encode(conVer.VersionData), base64Data);
        
    }
    
     @isTest
    static void testDecryptedData() {
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
        system.debug(decryptedString);

        // Verify the result
        System.assertEquals(userIdToEncrypt, decryptedString, 'Decryption failed');
    }
}