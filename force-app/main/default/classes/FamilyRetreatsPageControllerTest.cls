@isTest
public class FamilyRetreatsPageControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(LastName = 'TestContact', AccountId = testAccount.Id, Email = 'test@gmail.com');
        insert testContact;
        
        Property__c prop = new Property__c();
        prop.Name = 'Test Prop';
        prop.Portal_Description__c = 'Test Description';
        prop.Available_for_booking_portal__c = true;
        prop.Guests__c = 4;
        prop.Address__c = 'Test Address here';
        prop.State__c = 'NSW';
        prop.Length_of_stay__c = '8 days (7 nights)';
        insert prop;
        
        ContentVersion cvlist = new Contentversion();        
        cvlist.Title = 'CZDSTOU';         
        cvlist.PathOnClient = 'test';         
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');         
        List<ContentVersion> cvl = new List<ContentVersion>();         
        cvl.add(cvlist);         
        insert cvl;
        
        Retreat_Booking__c testBooking = new Retreat_Booking__c(
            Account__c = testAccount.Id,
            Contact__c = testContact.Id,
            Check_In_Date__c = Date.today(),
            Check_Out_Date__c = Date.today().addDays(7),
            Status__c = 'Waitlisted Q1',
            Property__c = prop.Id
        );
        insert testBooking;
    }
    
    @isTest
    static void testGetPropData() {
        // Call the method to be tested
        Test.startTest();
        //List<Retreat_Booking__c> result = FamilyRetreatsPageController.getPropData();
              ContentVersion conVer = [SELECT ID, VersionData, FirstPublishLocationId, Title from ContentVersion WHERE Title like '%CZ%'];        

        Contact con = [Select Id,FirstName,LastName,Email FROM Contact WHERE LastName LIKE '%Test%' LIMIT 1];
        System.debug('con --------------' + con);
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        System.debug('con --------------' + CommunityProfile);

        User us = new User(
            //IsActive=userActive,
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            UserName=con.Email,
            Alias=con.Email.subString(0, 7),
            FirstName=con.FirstName,
            LastName=con.LastName
        );
        
        System.runAs(us){
            String userIdToEncrypt = us.Id;
            Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
            Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
            String encryptedString = EncodingUtil.base64Encode(cipherText);
            FamilyRetreatsPageController.getPropData(encryptedString);
            List<FamilyRetreatsPageController.FetchRetreatDataWrap> wrapList = FamilyRetreatsPageController.getPropData(encryptedString);  
            Assert.isNotNull(wrapList);
        }    
        
        String base64Data = FamilyRetreatsPageController.contentVersion(conVer.Id);
        // Assert that the method returns the expected base64 encoded data
        System.assertEquals(EncodingUtil.base64Encode(conVer.VersionData), base64Data);
        
        Test.stopTest();
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