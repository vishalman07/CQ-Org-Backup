@istest
public class FamilyMyProfilePageControllerTest {
    
    @testSetup
    public static void testSetup(){
        
        Account ac = new Account();
        ac.Name = 'test';
        ac.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Family').getRecordTypeId();
        ac.Preferred_Event_Locations__c = 'Sydney';
        ac.Family_Interests__c = 'Sports';
        ac.media_opt_in_take_video_photos__c = true;
        ac.media_opt_in_share_participants__c = true;
        ac.Media_permission_Public_2019__c = false;
        ac.Media_permission_corporate_2019__c = true;
        ac.media_opt_in_share_participants_child__c = true;
        ac.Media_permission_Public_2019_Child__c = false;
        ac.Image_Opt_In_Permission_Corporate_Child__c = true;
        //ac.Image_Opt_In_Participant_Sharing__c = true;
        ac.Home_Phone__c = '4477812345';
        ac.Mobile_Phone__c = '1132557675383';
        insert ac;
        
        Contact con = new Contact();
        con.AccountId = ac.Id;
        con.Swimming_Ability__c = '	0-25m';
        con.Shirt_Size__c = 'Kids 6';
        con.LastName = 'testCon';
        con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Family_Member').getRecordTypeId();
        con.Email = 'testCon@gmail.com ';
        con.MailingCity = 'Delhi';
        con.MailingStreet = 'testConStreet';
        con.MailingState = 'UP';
        con.MailingPostalCode = '443322';
        con.MailingCountry = 'UK';
        con.Family_Member_Type__c = 'Father';
        con.Birthdate = System.today() - 5;
        con.npsp__Deceased__c = false;
        con.Exclude_From_Portal__c = false;
        insert con;
        
        Contact cont = new Contact();
        cont.AccountId = ac.Id;
        cont.Swimming_Ability__c = '0-25m';
        cont.Shirt_Size__c = 'Kids 6';
        cont.LastName = 'testCon2';
        cont.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Family_Member').getRecordTypeId();
        cont.Email = 'testCon@gmail.com ';
        cont.MailingCity = 'Delhi';
        cont.MailingStreet = 'testConStreet';
        cont.MailingState = 'UP';
        cont.MailingPostalCode = '443322';
        cont.MailingCountry = 'UK';
        cont.Family_Member_Type__c = 'Father';
        cont.Birthdate = System.today() - 4;
        cont.npsp__Deceased__c = false;
        cont.Exclude_From_Portal__c = false;
        insert cont;
        
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
        
        Special_Needs__c spDietNeed  = new Special_Needs__c();
        spDietNeed.Contact__c = con.Id;
        spDietNeed.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId();
        spDietNeed.Long_Description__c = 'Allergic - All Nuts';
        spDietNeed.Comments__c = 'deleteDiet';  
        insert spDietNeed; 
        
        Site__c si = new Site__c();
        si.Name = 'Camp Quality Families';
        si.Required_Permission_Set__c = 'Family_Portal_Permissions';
        si.Contact_Access_Field__c = 'testContact';
        si.Site_URL__c = 'TestSiteURL';
        insert si;
        
        Page__c pg = new Page__c();
        pg.Content__c = 'text contect on a page';
        pg.Title__c = 'Frequently Asked Questions';
        pg.Name = 'Home Page';
        pg.Site__c = si.Id;
        insert pg;
        
    }
    
    
    @istest
    public static void testFamilyData(){
        
        Test.startTest();       
        Contact con = [Select Id,FirstName,LastName,Email, AccountId FROM Contact WHERE LastName LIKE '%test%' LIMIT 1];
		List<Contact> conList = [Select Id,FirstName,LastName,Email, AccountId FROM Contact WHERE LastName = 'testCon2' LIMIT 1];
        
        List<Special_Needs__c> spNeedDiet = [Select Id,RecordTypeId,Long_Description__c,Comments__c,Contact__c FROM Special_Needs__c WHERE Contact__c =:con.Id];
        System.assertNotEquals(0, spNeedDiet.size(), 'Expected at least one Special_Needs__c record for the contact');
        System.assertNotEquals(null, con.Id, 'Contact record Id cannot be null');
        System.debug('spNeedDiet------->' + spNeedDiet);
        
        Special_Needs__c speDietry;
        Special_Needs__c speNeed;
        Special_Needs__c speDelete;
        List<FamilyMyProfilePageController.DietWrapper> dietWrap = new List<FamilyMyProfilePageController.DietWrapper>();
        List<FamilyMyProfilePageController.SpeNeedWrapper> spWrap = new List<FamilyMyProfilePageController.SpeNeedWrapper>();

        
        
        
        for(Special_Needs__c spn : spNeedDiet){
            if(spn.recordTypeId == Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId()){
                FamilyMyProfilePageController.SpeNeedWrapper spNeed = new FamilyMyProfilePageController.SpeNeedWrapper();
                spNeed.specNeedDescription = spn.Long_Description__c;
                spNeed.specNeedComment = spn.Comments__c;
                spNeed.id = spn.Id;
                spNeed.recordId = spn.Id;
                spWrap.add(spNeed);
                speNeed = spn;
                
                FamilyMyProfilePageController.SpeNeedWrapper spNeed2 = new FamilyMyProfilePageController.SpeNeedWrapper(); // handle null recordId case
                spNeed2.specNeedDescription = spn.Long_Description__c;
                spNeed2.specNeedComment = spn.Comments__c;
                spNeed2.id = spn.Id;
                spNeed2.recordId = null;
                spWrap.add(spNeed2);
                speNeed = spn;
                
                System.assertEquals(2, spWrap.size(), 'Expected 2  Special_Needs__c records to be processed as special needs');
            }
            else if(spn.recordTypeId == Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId()){
                if(spn.Comments__c == 'testComments'){
                    
                    FamilyMyProfilePageController.DietWrapper diet = new FamilyMyProfilePageController.DietWrapper();
                    diet.recordId = spn.Id;
                    diet.id = spn.Id;
                    diet.dietComment = spn.Comments__c;
                    diet.dietDescription = spn.Long_Description__c;
                    dietWrap.add(diet);
                    //speDietry.add(spn);
                    speDietry = spn;
                    System.assertEquals('testComments', dietWrap[0].dietComment, 'Expected dietary_Requirement to have a comment of "testComments"');
                   

                    FamilyMyProfilePageController.DietWrapper diet2 = new FamilyMyProfilePageController.DietWrapper(); // handle null recordId case
                    diet2.recordId = null;
                    diet2.id = spn.Id;
                    diet2.dietComment = spn.Comments__c;
                    diet2.dietDescription = spn.Long_Description__c;
                    dietWrap.add(diet2);
                    //speDietry.add(spn);
                    speDietry = spn;
                    
                    System.assertEquals(2, dietWrap.size(), 'Expected 2 Special_Needs__c records to be processed as dietary requirements');
                }
                
                else{
                    //speDelete.add(spn);
                    speDelete = spn;
                }
            }           
        }
        
        Profile pr = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        
            User us = new User(
            ContactId=con.Id,
            ProfileId=pr.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName
        );
        
        
        System.runas(us){
            String userIdToEncrypt = UserInfo.getUserId();
            Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
            Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
            String encryptedString = EncodingUtil.base64Encode(cipherText);
            FamilyMyProfilePageController.locationInProfile();
            FamilyMyProfilePageController.familyInterestData();
            FamilyMyProfilePageController.getFamilyProfiledata(encryptedString);
            FamilyMyProfilePageController.getConDatafortable(encryptedString);
            FamilyMyProfilePageController.getTableBtnData(conList[0].Id);
            
           // String jsonData = '{"email":"newemail@as.com","street":"Mailing address ical Centre-Negombo Sri Lanka .","postalCode":"0044433","country":"Sri Lanka","city":"Negombo","state":"StateTest 2","preferredEventLocations":"Illawarra;Sydney;South Queensland;Victoria;Newcastle","familyInterest":"Circus","homePhone":"11199999900000","mobilePhone":"789456321","shirtSize":"Kids 2","swimmingAbility":"0-25m","name":"","relationship":"","birthday":"2023-11-22","conId":" '+con.Id+ '","contactList":[{"attributes":{"type":"Contact","url":"/services/data/v59.0/sobjects/Contact/con.Id"},"Id":"'+con.Id+'","AccountId":"'+con.AccountId+'","Name":"Amit Test","Swimming_Ability__c":"0-25m","Shirt_Size__c":"Kids 2"},{"attributes":{"type":"Contact","url":"/services/data/v59.0/sobjects/Contact/con.Id"},"Id":"'+con.Id+'","AccountId":"'+con.AccountId+'","Name":"test2.0","Swimming_Ability__c":"50m and above"}],"mediaOptInTakeVideoPhotos":true,"mediaOptInShareParticipants":false,"mediaPermissionPublic2019":true,"mediaOptInShareParticipantsChild":true,"mediaPermissionPublic2019Child":true,"imageOptInPermissionCorporateChild":true,"mediapermissioncorporate2019":true}';
            
            FamilyMyProfilePageController.WrapperVoluteerData wrap = new FamilyMyProfilePageController.WrapperVoluteerData();
            wrap.shirtSize = 'Kids 4';
            wrap.swimmingAbility = '25-50m';                       
            wrap.speNeedList = spWrap;
            wrap.dietList = dietWrap;
            wrap.conId = con.Id;
            wrap.mediaOptInShareParticipants = true;
            wrap.mediaOptInTakeVideoPhotos = false;
            wrap.mediaPermissionPublic2019 = true;
            wrap.mediaOptInShareParticipantsChild = false;
            wrap.mediaPermissionPublic2019Child = true;
            wrap.imageOptInPermissionCorporateChild = false;
            wrap.mediapermissioncorporate2019 = true;

            String jsdata = JSON.serialize(wrap);
			FamilyMyProfilePageController.savefamilyData(jsdata, encryptedString);
            FamilyMyProfilePageController.updatetableData(jsdata, con.Id);
            
        }
        
        FamilyMyProfilePageController.homePageContect();
        FamilyMyProfilePageController.contactUs('Request a call', 'testingDetails' , 'Complex functionality', us.Id);
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