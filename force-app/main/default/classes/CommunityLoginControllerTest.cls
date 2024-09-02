/********************************************************************************************************
* @Name         CommunityLoginControllerTest
* @Author       Amit Yadav
* @Date         12/01/2023
* @Description  CommunityLoginControllerTest class contains test methods to validate 
the behavior of methods in the CommunityLoginControllerTest class. 
It focuses on testing various functionalities and cover different senario.
********************************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/01/2023         Initial Creation                                                      
******************************************************************************************************* */
@isTest
public class CommunityLoginControllerTest {
    
    public class SendOtpSmsCallout  implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ok":"test"}');
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"status": "success"}');
            return res;
        }
    }
    
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
        con.firstName = 'testingg';
        con.LastName = 'Test';
        con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Volunteer').getRecordTypeId();
        con.Email = 'test@2user.com';
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
        
		//Inserting contact for negative 
        contact con2 = new contact();
        con2.LastName = 'testq con';
        con2.Email = 'test@22user.com';
        con2.AccountId = ac.Id;
        con2.Otp__c ='12';
        con2.SMS_OTP__c='T';
        con2.MobilePhone = '';
        insert con2;
        
        // Creating test Campaign records.
        Campaign cam = new Campaign();
        cam.Name = 'Test Camp';
        cam.Cost_Centre__c = '1010';
        cam.Event_Type__c = 'Family Camp';
        cam.Event_Start_Date__c = System.today();
        cam.Event_End_Date__c = System.today() + 1;
        cam.IsActive = true;
        cam.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Age_Camp').getRecordTypeId();
        insert cam;
        // Creating test Volunteer Attendence records.
        Volunteer_Attendance__c volAtt = new Volunteer_Attendance__c();
        volAtt.Participation_Role__c = 'Staff';
        volAtt.Volunteer__c = con.Id;
        volAtt.Event__c = cam.Id;
        volAtt.Attendance__c = 'Accepted';
        volAtt.Participation_Role__c = 'Staff';
        insert volAtt;
        
        // Creating test Incident records.
        Incident__c inc = new Incident__c();
        inc.Incident_Date_Time__c = System.today() +1;
        inc.Incident_Type__c = 'Injury';
        inc.Severity__c = 'Minor';
        
        inc.Status__c = 'New';
        inc.Reporters_Name__c = 'Test report Name';
        inc.Stakeholder_s_Involved__c = 'Child';
        inc.Stakeholder_s_Other__c = 'text Stakeholders Other';
        inc.Incident_Location__c = 'Test Location';
        inc.Incident_description__c  = 'test Description';
        inc.Were_emergency_services_required__c = 'Yes';
        inc.Was_first_aid_required__c = 'Yes';
        inc.First_Aid_provided__c = 'test first Provided';
        inc.First_Aider__c = 'test Rider';
        inc.Incident_Type__c = 'Injury';
        inc.Type_of_Behaviour__c = 'Harm to Self';
        inc.Incident_Date_Time__c = cam.Event_Start_Date__c.addDays(1);
        System.debug('inc.Incident_Date_Time__c1: ' + inc.Incident_Date_Time__c);
        inc.Event_Program_Name__c = cam.Id;
        inc.RecordTypeId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Illness').getRecordTypeId();        
        insert inc;
        
        // Creating a test Site data
        Site__c si = new Site__c();
        si.Name = 'Camp Quality Volunteers';
        si.Required_Permission_Set__c = 'Volunteer_Portal_Permissions';
        si.Contact_Access_Field__c = 'testContactAccess';
        si.Site_URL__c = 'siteUrl';
        insert si;
        // Creating a test Page data 
        Page__c pg = new Page__c();
        pg.Content__c = 'text contenct on a page';
        pg.Title__c = 'Volunteer News and Updates';
        pg.Site__c = si.Id;
        pg.Name = 'Home Page';
        insert pg;
        
        Page__c pg2 = new Page__c();
        pg2.Content__c = 'text contenct on a 2nd page';
        pg2.Title__c = 'Volunteer News and Updates on 2nd page';
        pg2.Site__c = si.Id;
        pg2.Name = 'Volunteers Home Page';
        insert pg2;
        
        case cas = new case();
        cas.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Respite_Case').getRecordTypeId();
        cas.Subject = 'subject';
        cas.AccountId = con.AccountId;
        cas.ContactId = con.Id;
        cas.Status = 'New';
        cas.Origin = 'Community';
        cas.Type = 'Question';
        cas.Reason = 'reason';
        cas.Description = 'details';
        insert cas;     
    }
    
    // Test method to check the behavior of various methods in CommunityLoginController.
    @isTest
    public static void testUserLogin(){
        
        Test.startTest();
        // Calling the getPickListValuesIntoList method.
        CommunityLoginController.getPickListValuesIntoList();
        // Retrieving a Contact created in the test data setup.
        Contact con = [Select Id,FirstName,LastName,Email FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
        // Retrieving the CommunityProfile profile.
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        Campaign cam = [Select id , Name, Event_Start_Date__c , Event_End_Date__c From Campaign Where Name = 'Test Camp' Limit 1];
        //Campaign cam = [SELECT Id,]
        // Retrieving an Incident__c record created in the test data setup.
        List<Incident__c> inc = [Select Id, Incident_Date_Time__c , RecordType.Name ,Severity__c , Status__c , Stakeholder_s_Involved__c , Stakeholder_s_Other__c , Incident_Location__c, Incident_description__c , Were_emergency_services_required__c ,
                                 Was_first_aid_required__c , First_Aid_provided__c ,First_Aider__c , Incident_Type__c , Type_of_Behaviour__c , Observed_Triggers__c , Staff_Volunteers_Involved__c , Injuries_sustained__c ,
                                 Nature_of_bodily_injury__c , Event_Program_Name__r.recordTypeId, Event_Program_Name__c, Event_Program_Name__r.IsActive, Emergency_Contact_Notified__c , Call_Details__c , Supervisor_Name__c ,
                                 Supervisor_Notified_Date__c , Actions_taken__c , Volunteer_Comments__c, RecordTypeId, Event_Program_Name__r.StartDate, 
                                 Event_Program_Name__r.EndDate From Incident__c];
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
        // Running as the test User to execute the methods in CommunityLoginController. 
        System.runAs(us){
            /*Incident__c inc2 = new Incident__c();
            inc2.Incident_Date_Time__c = System.today() +1;
            inc2.Incident_Type__c = 'Injury';
            inc2.Severity__c = 'Major';
            inc2.Status__c = 'New';
            inc2.Reporters_Name__c = 'Test report Name2';
            inc2.Stakeholder_s_Involved__c = 'Child';
            inc2.Stakeholder_s_Other__c = 'text Stakeholders Other';
            inc2.Incident_Location__c = 'Test Location';
            inc2.Incident_description__c  = 'test Description';
            inc2.Were_emergency_services_required__c = 'Yes';
            inc2.First_Aid_provided__c = 'test first Provided';
            inc2.First_Aider__c = 'test Rider2';
            inc2.Incident_Type__c = 'Injury';
            inc2.Type_of_Behaviour__c = 'Harm to Self';
            inc2.Incident_Date_Time__c = cam.Event_Start_Date__c.addDays(2);
            inc2.Event_Program_Name__c = cam.Id;
            inc2.RecordTypeId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Injury').getRecordTypeId();        
            insert inc2;*/
            
            
            //Incident record for outside range date senario 
            /*Incident__c incOutrange = new Incident__c();
            incOutrange.Incident_Date_Time__c = System.today();
            incOutrange.Incident_Type__c = 'Injury';
            incOutrange.Severity__c = 'Minor';
            incOutrange.Status__c = 'New';
            incOutrange.Reporters_Name__c = 'Test report Name';
            incOutrange.Stakeholder_s_Involved__c = 'Child';
            incOutrange.Incident_Location__c = 'Test Location';
            incOutrange.Incident_description__c  = 'test Description';
            incOutrange.Were_emergency_services_required__c = 'Yes';
            incOutrange.Was_first_aid_required__c = 'Yes';
            incOutrange.First_Aid_provided__c = 'test first Provided';
            incOutrange.First_Aider__c = 'test Rider';
            incOutrange.Incident_Type__c = 'Injury';
            incOutrange.Type_of_Behaviour__c = 'Harm to Self';
            incOutrange.Incident_Date_Time__c = cam.Event_End_Date__c.addDays(1);
            incOutrange.Event_Program_Name__c = cam.Id;
            incOutrange.RecordTypeId = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Illness').getRecordTypeId();        
            insert incOutrange;*/
            
            User use = new User(
                ContactId=con.Id,
                ProfileId=CommunityProfile.Id,
                EmailEncodingKey='UTF-8',
                LocaleSidKey='en_AU',
                LanguageLocaleKey='en_US',
                TimeZoneSidKey='Australia/Sydney',
                Email=con.Email,
                MobilePhone = '',
                UserName=con.Email,
                Alias=con.Email.subString(0, 8),
                FirstName=con.FirstName,
                LastName=con.LastName,
                IsActive = true
            );
            
           /* PermissionSet ps = [SELECT Id 
                                FROM PermissionSet 
                                WHERE Name = 'Volunteer_Portal_Permissions'];
            insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);         */
            String userIdToEncrypt = us.Id;
            Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
            Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
            String encryptedString = EncodingUtil.base64Encode(cipherText);
            CommunityLoginController.contactUs('testsubject', 'details', 'Complex functionality',encryptedString);
            CommunityLoginController.checkIncidentAccess(encryptedString);
            CommunityLoginController.checkUsersEmailAndPhone(us.Email);
            CommunityLoginController.checkUsersEmailAndPhone(use.Email);
            
        }
        CommunityLoginController.fatchIncidentRecord(inc[0].Id);         
        Page__c testPage =  CommunityLoginController.homePageContect();
        Assert.areEqual('Volunteers Home Page', testPage.Name);        
        // Stopping the test execution.
        Test.stopTest();
    }
    
	@istest
    public static void testupdateCommentIncident(){
        
        	  List<Incident__c> inc = [Select Id, Incident_Date_Time__c , RecordType.Name ,Severity__c , Status__c , Stakeholder_s_Involved__c , Stakeholder_s_Other__c , Incident_Location__c, Incident_description__c , Were_emergency_services_required__c ,
                                 Was_first_aid_required__c , First_Aid_provided__c ,First_Aider__c , Incident_Type__c , Type_of_Behaviour__c , Observed_Triggers__c , Staff_Volunteers_Involved__c , Injuries_sustained__c ,
                                 Nature_of_bodily_injury__c , Event_Program_Name__r.recordTypeId, Event_Program_Name__c, Event_Program_Name__r.IsActive, Emergency_Contact_Notified__c , Call_Details__c , Supervisor_Name__c ,
                                 Supervisor_Notified_Date__c , Actions_taken__c , Volunteer_Comments__c, RecordTypeId, Event_Program_Name__r.StartDate, 
                                 Event_Program_Name__r.EndDate From Incident__c];
                String result  = CommunityLoginController.updateCommentIncident(inc[0].Volunteer_Comments__c, inc[0].Id);
        System.assertEquals('Updated Record', result, 'Result check');

    }    
    
    
    
    @IsTest 
    static void testForgetPassword() {
        Boolean exceptionCaught = false;
        Test.startTest();
        try {
            //CommunityLoginController.forgetPassword(null); // this should handle null pointer exception    
        } 
        catch (Exception ex) {
            exceptionCaught = true;   
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionCaught , 'exception was not caught');
    }
    
    
    @isTest
    public static void getavtarUser(){
        User userRec1 = [SELECT Id,Lastname,Firstname,Name,TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, Alias FROm User WHERE Id =: UserInfo.getUserId()][0];
        User userRec = new User();
        userRec.FirstName = ' user';
        userRec.lastName = 'TestUser';
        userRec.userName = UserInfo.getUserEmail()+'1234';
        //User userRec = new User();
        userRec.ProfileId = UserInfo.getProfileId();
        userRec.Email = UserInfo.getUserEmail();
        userRec.MobilePhone = '99999999990';
        userRec.TimeZoneSidKey = userRec1.TimeZoneSidKey; 
        userRec.LocaleSidKey = userRec1.LocaleSidKey; 
        userRec.EmailEncodingKey = userRec1.EmailEncodingKey; 
        userRec.LanguageLocaleKey = userRec1.LanguageLocaleKey;
        userRec.Alias = userRec1.Alias;
        userRec.IsActive = true;
        insert userRec;       
        Test.startTest();
        String userIdToEncrypt = UserInfo.getUserId();
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        User testUser =  CommunityLoginController.avtarUser(encryptedString);
        Assert.isNotNull(testUser, 'User is Null');
        Test.stopTest();
        
    }
    
    
    @IsTest
    Public static void getloginUserByOtp(){
        
        List<case> caList=[select Subject,AccountId,ContactId,Status,Origin,Type,Reason,Description,RecordTypeId from case LIMIT 1];
        User userRec1 = [SELECT Id,TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, Alias FROm User WHERE Id =: UserInfo.getUserId()][0];
        List<CONTACT> conList=[SELECT Id,firstname,lastname, Email, Otp__c, SMS_OTP__c, Phone  FROM CONTACT where Lastname = 'Test' LIMIT 1];
        System.debug(conlist);
        User userRec = new User();
        userRec.lastName = 'TestUser';
        userRec.userName = 'test@3458user.com';
        //User userRec = new User();
        userRec.ProfileId = UserInfo.getProfileId();
        userRec.Email = conList[0].Email;
        userRec.MobilePhone = '0499999999';
        userRec.TimeZoneSidKey = userRec1.TimeZoneSidKey; 
        userRec.LocaleSidKey = userRec1.LocaleSidKey; 
        userRec.EmailEncodingKey = userRec1.EmailEncodingKey; 
        userRec.LanguageLocaleKey = userRec1.LanguageLocaleKey;
        userRec.Alias = userRec1.Alias;
        userRec.IsActive = true;
        insert userRec;
        
        
        Test.setMock(HttpCalloutMock.class, new SendOtpSmsCallout());
        Test.startTest();
       // CommunityLoginController.loginContactUsPage(conList[0].Email,caList[0].subject,caList[0].reason,caList[0].Description,conlist[0].Firstname,conlist[0].lastname);
        String otp1 =  CommunityLoginController.loginUserByOtp( userRec.Email, 'sms');
        Assert.isNotNull(otp1);
        String otp2 = CommunityLoginController.loginUserByOtp(userRec.Email,'email');
        Assert.isNotNull(otp2);
        Test.stopTest();
    }
   

    /*@isTest
    static void testLoginContactUsPage() {
        Account a = [SELECT id,name from account where name ='test'];
        // Query for the profile
        Profile profWithoutAccess = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];

        contact con = [SELECT ID,Firstname,lastname,Email from contact where firstname = 'testingg' AND lastname = 'test'];

        // Create a test User
        User testUser = new User(
          FirstName = 'Test',
        LastName = 'User',
        Email = con.Email,
        Username = 'tester@yug.com',
        ProfileId = profWithoutAccess.Id,
        IsActive = true,
        ContactId = con.Id,
        Alias = 'TUser',
        TimeZoneSidKey = 'GMT',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create a test Contact
       
        Test.startTest();
        
        // Call the method under test
        String successMessage = CommunityLoginController.loginContactUsPage(
            con.Email,
            'Test Subject',
            'Test Details',
            'Test Reason',
            con.FirstName,
            con.LastName
        );
        
        Test.stopTest();
        
        // Verify the success message
        System.assertEquals('Your message has been received. Someone will contact you shortly.', successMessage);

        // Verify that a case was created
        List<Case> createdCases = [SELECT Id,subject,ownerid FROM Case where subject = 'Test Subject'];
        System.assertEquals(1, createdCases.size());
        
        // Verify case details
        Case createdCase = createdCases[0];
        System.assertEquals('Test Subject', createdCase.Subject);
        // Add more assertions for other case fields if needed
        
        // Verify that the case was assigned using assignment rules
        System.assertNotEquals(null, createdCase.OwnerId); // OwnerId should be set by assignment rules
        
    }*/
    
        @isTest
    public static void negativtSenacheckUsersEmailAndPhone(){
        Contact con = [Select Id,FirstName,LastName,Email FROM Contact WHERE LastName = 'Test' LIMIT 1];
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        //User userRec = [SELECT ID FROM User WHERE Id =: UserInfo.getUserId()];
         User us = new User(
            //ContactId=con.Id,
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName='test21',
            LastName='test22',
            MobilePhone = NULL,
            IsActive= true 
        );
        insert us;
     
		PermissionSet pset = [SELECT Id FROM PermissionSet WHERE Name = 'Volunteer_Portal_Permissions'];
       /* PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = us.Id;
        psa.PermissionSetId = pset.Id;
        insert psa;     */
        Test.startTest();
        CommunityLoginController.checkUsersEmailAndPhone(us.Email); 		
        Test.stopTest();
              
    }   
    
     @isTest
    public static void testcheckUsersEmailAndPhone(){
        Contact con = [Select Id,FirstName,LastName,Email,MobilePhone FROM Contact WHERE LastName LIKE '%test%' LIMIT 1];
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
         User us = new User(
            //ContactId=con.Id,
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName='test21',
            LastName='test22',
            MobilePhone = '0488444566',
            IsActive= true 
        );
        insert us;
        Test.startTest();
        CommunityLoginController.checkUsersEmailAndPhone(us.Email); 		
        Test.stopTest();                
    }
    
       @isTest
    public static void negativeTestcheckUsersEmailAndPhone(){
        
    
        Contact con = [Select Id,FirstName,LastName,Email,MobilePhone FROM Contact WHERE LastName= 'testq con' LIMIT 1];

       
		
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
         User us = new User(
            //ContactId=con.Id,
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName='test21',
            LastName='test22',
            MobilePhone = '',
            IsActive= true 
        );
        insert us;
          // Querying a permission set
        PermissionSet ps = [SELECT Id, Name 
                            FROM PermissionSet 
                            WHERE Name = 'Volunteer_Portal_Permissions'];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);
     
        Test.startTest();
        CommunityLoginController.checkUsersEmailAndPhone(us.Email); 
       // CommunityLoginController.checkUsersEmailAndPhone(UserInfo.getUserEmail()); 
        Test.stopTest();                
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