/********************************************************************************************************
* @Name         FamilyPortalLoginControllerTest
* @Author       Amit Yadav
* @Date         12/01/2023
* @Description  FamilyPortalLoginControllerTest class contains test methods to validate 
				the behavior of methods in the FamilyPortalLoginControllerTest class. 
				It focuses on testing various functionalities and cover different senario.
********************************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/02/2023         Initial Creation                                                      
******************************************************************************************************* */
@IsTest
public class FamilyPortalLoginControllerTest{
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setBody('{"status": "success"}');
            return res;
        }
    }
    @testSetup static void createTestData(){
        
        Account accRec = new Account();
        accRec.Name= 'Test Account';
        accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organisation').getRecordTypeId();
        insert accRec;
        
        List<CONTACT> conList=new List<CONTACT>();
        contact con = new contact();
        con.LastName = 'test con';
        con.Email = 'test@2user.com'; 
        con.MobilePhone = '0499999990';
        con.AccountId = accRec.Id;
        con.Otp__c ='12';
        con.SMS_OTP__c='T';
        con.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Volunteer').getRecordTypeId();
        conList.add(con);
        insert conList;

		contact con2 = new contact();
        con2.LastName = 'testq con';
        con2.Email = UserInfo.getUserEmail();
        con2.AccountId = accRec.Id;
        con2.Otp__c ='12';
        con2.SMS_OTP__c='T';
        con2.MobilePhone = NULL;
        insert con2;
              
    }
    @IsTest
    public static void getUserMail(){
        Contact con = [Select Id,FirstName,LastName,Email FROM Contact WHERE LastName LIKE '%test%' LIMIT 1];
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
            //MobilePhone = '888444566',
            IsActive= true 
        );
        insert us;
     
		PermissionSet pset = [SELECT Id FROM PermissionSet WHERE Name = 'Family_Portal_Permissions'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = us.Id;
        psa.PermissionSetId = pset.Id;
        insert psa;     
        Test.startTest();
        FamilyPortalLoginController.checkUsersEmailAndPhone(us.Email); 		
        Test.stopTest();              
    }
    
    @isTest
    public static void testcheckUsersEmailAndPhone(){
        Contact con = [Select Id,FirstName,LastName,Email,MobilePhone FROM Contact WHERE LastName LIKE '%test%' LIMIT 1];
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
            MobilePhone = '0488444566',
            IsActive= true 
        );
        insert us;
     
		PermissionSet pset = [SELECT Id FROM PermissionSet WHERE Name = 'Family_Portal_Permissions'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = us.Id;
        psa.PermissionSetId = pset.Id;
        insert psa;     
        Test.startTest();
        FamilyPortalLoginController.checkUsersEmailAndPhone(us.Email); 		
        Test.stopTest();                
    }

	
    @isTest
    public static void negativtSenacheckUsersEmailAndPhone(){
        Contact con = [Select Id,FirstName,LastName,Email FROM Contact WHERE LastName = 'testq con' LIMIT 1];
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
     
		PermissionSet pset = [SELECT Id FROM PermissionSet WHERE Name = 'Family_Portal_Permissions'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = us.Id;
        psa.PermissionSetId = pset.Id;
        insert psa;     
        Test.startTest();
        FamilyPortalLoginController.checkUsersEmailAndPhone(us.Email); 		
        Test.stopTest();
        
        
    }
    @IsTest
    Public static void getloginUserByOtp(){
        User userRec1 = [SELECT Id,Email,TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, Alias FROm User WHERE Id =: UserInfo.getUserId()][0];
        List<CONTACT> conList=[SELECT Id, Email, Otp__c, SMS_OTP__c, Phone  FROM CONTACT where Email=: userRec1.Email];
        
        System.debug(conlist);
        User userRec = new User();
        userRec.lastName = 'TestUser';
        userRec.userName = 'test@23user.com';
        userRec.ProfileId = UserInfo.getProfileId();
        userRec.Email = 'test@2user.com';
        userRec.MobilePhone = '0499999990';
        userRec.TimeZoneSidKey = userRec1.TimeZoneSidKey; 
        userRec.LocaleSidKey = userRec1.LocaleSidKey; 
        userRec.EmailEncodingKey = userRec1.EmailEncodingKey; 
        userRec.LanguageLocaleKey = userRec1.LanguageLocaleKey;
        userRec.Alias = userRec1.Alias;
        userRec.IsActive = true;
        insert userRec;
        
        User userRecMob = new User();
        userRecMob.lastName = 'TestUser';
        userRecMob.userName = 'test@2553user.com';
        userRecMob.ProfileId = UserInfo.getProfileId();
        userRecMob.Email = 'test@4572user.com';
        userRecMob.MobilePhone = '+6199999990';
        userRecMob.TimeZoneSidKey = userRec1.TimeZoneSidKey; 
        userRecMob.LocaleSidKey = userRec1.LocaleSidKey; 
        userRecMob.EmailEncodingKey = userRec1.EmailEncodingKey; 
        userRecMob.LanguageLocaleKey = userRec1.LanguageLocaleKey;
        userRecMob.Alias = userRec1.Alias;
        userRecMob.IsActive = true;
        insert userRecMob;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        FamilyPortalLoginController.loginUserByOtp(userRec.Email, 'sms');
        FamilyPortalLoginController.loginUserByOtp(userRec.Email,'email');
		FamilyPortalLoginController.loginUserByOtp(userRec.Email,'');
		FamilyPortalLoginController.loginUserByOtp(userRecMob.Email, 'sms');
        Test.stopTest();
    }
    
     @IsTest
    Public static void getloginUserByOtpNegativeSenario(){
        User userRec1 = [SELECT Id,Email,TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, Alias FROm User WHERE Id =: UserInfo.getUserId()][0];
        //List<CONTACT> conList=[SELECT Id, Email, Otp__c, SMS_OTP__c, Phone  FROM CONTACT where Email=: userRec1.Email];
        List<CONTACT> conList=[SELECT Id, Email, Otp__c, SMS_OTP__c, Phone, MobilePhone  FROM CONTACT where LastName = 'test con'];

        
        System.debug(conlist);
        User userRec = new User();
        userRec.lastName = 'TestUser';
        userRec.userName = 'test@23user.com';
        userRec.ProfileId = UserInfo.getProfileId();
        userRec.Email = 'test@2user.com';
        userRec.MobilePhone = '0499999990';
        userRec.TimeZoneSidKey = userRec1.TimeZoneSidKey; 
        userRec.LocaleSidKey = userRec1.LocaleSidKey; 
        userRec.EmailEncodingKey = userRec1.EmailEncodingKey; 
        userRec.LanguageLocaleKey = userRec1.LanguageLocaleKey;
        userRec.Alias = userRec1.Alias;
        userRec.IsActive = true;
        insert userRec;
        
        User userRecMob = new User();
        userRecMob.lastName = 'TestUser';
        userRecMob.userName = 'test@2553user.com';
        userRecMob.ProfileId = UserInfo.getProfileId();
        userRecMob.Email = 'test@4572user.com';
        userRecMob.MobilePhone = '+6199999990';
        userRecMob.TimeZoneSidKey = userRec1.TimeZoneSidKey; 
        userRecMob.LocaleSidKey = userRec1.LocaleSidKey; 
        userRecMob.EmailEncodingKey = userRec1.EmailEncodingKey; 
        userRecMob.LanguageLocaleKey = userRec1.LanguageLocaleKey;
        userRecMob.Alias = userRec1.Alias;
        userRecMob.IsActive = true;
        insert userRecMob;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        FamilyPortalLoginController.loginUserByOtp(userRec.Email, 'sms');
        FamilyPortalLoginController.loginUserByOtp(userRec.Email,'email');
		FamilyPortalLoginController.loginUserByOtp(userRec.Email,'');
		FamilyPortalLoginController.loginUserByOtp(userRecMob.Email, 'sms');
        Test.stopTest();
    }
    
    
     
    
    @IsTest
    public static void getavtarUser(){
        User userRec1 = [SELECT Id,Lastname,Firstname,Name,TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, Alias FROm User WHERE Id =: UserInfo.getUserId()][0];
        User userRec = new User();
        
        userRec.FirstName = ' user';
        userRec.lastName = 'TestUser';
        userRec.userName = UserInfo.getUserEmail() + '111';
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
        String userIdToEncrypt = userRec.Id;
        Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
       // String decryptedUserId = FamilyPortalLoginController.decryptedData(userRec.Id);
      //  System.debug('decryptedUserId' + decryptedUserId );
        Test.startTest();
        User returnedUser = FamilyPortalLoginController.avtarUser(encryptedString);
//        FamilyPortalLoginController.avtarUser(encryptedString);
        Test.stopTest();
        System.assertEquals(userRec.Id, returnedUser.Id);
        
    }
  @IsTest
         public static void testContactUs() {
         // Create a test user
         Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
         List<CONTACT> conList=[SELECT Id, Email, Otp__c, SMS_OTP__c, Phone, MobilePhone  FROM CONTACT where LastName = 'test con'];
        User testUser = new User(
        FirstName = 'Test',
        LastName = 'User',
        Email = 'testuser@example.com',
        Username = 'testuser@example.com',
        Alias = 'TUser',
        ProfileId = testProfile.Id,
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        ContactId = conList[0].Id
    );
    insert testUser;

    // Encrypt the test user's ID
  
	  String userIdToEncrypt = UserInfo.getUserId();
        Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);

    Test.startTest();
    String successMsg = FamilyPortalLoginController.contactUs('Test Subject', 'Test Details', 'Test Reason',encryptedString);
    Test.stopTest();

    // Check the result
   // System.assertNotEquals(null, successMsg);
}
     
  @isTest
    static void testencryptedData() {
        // Test data
        String userIdToEncrypt = UserInfo.getUserId() ;
        Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        
      

        // Call the method to test
        String decryptedString = FamilyPortalLoginController.decryptedData(encryptedString);
        system.debug(decryptedString);

        // Verify the result
        System.assertEquals(userIdToEncrypt, decryptedString, 'Decryption failed');
    }

	 @isTest
    static void testDecryptedData() {
        // Test data

		 String userIdToEncrypt = UserInfo.getUserId() ;
        Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        
        //String userIdToEncrypt = UserInfo.getUserId() ;
        Blob keyde = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
        Blob cipherTextde = Crypto.decryptWithManagedIV('AES128', keyde, cipherText);
        String encryptedString2 = EncodingUtil.base64Encode(cipherText);

        // Call the method to test
        String decryptedString = FamilyPortalLoginController.decryptedData(encryptedString2);
        system.debug(decryptedString);

        // Verify the result
        System.assertEquals(userIdToEncrypt, decryptedString, 'Decryption failed');
    }
    
}