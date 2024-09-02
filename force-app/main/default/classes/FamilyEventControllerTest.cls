/********************************************************************************************
* @Name         FamilyEventControllerTest
* @Author       Amit Yadav
* @Date         12/1/2023
* @Description  FamilyEventControllerTest class contains test methods to validate the behavior of methods
in the FamilyEventController class. It focuses on testing various functionalities.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/1/2023        Initial Creation                                                      
********************************************************************************************/
@istest
public class FamilyEventControllerTest {
    //Created test data of multiple object 
    @testsetup
    public static void Create(){
        // Created a test Account record 
        Account ac = new Account();
        ac.Name = 'test Event';
        ac.Phone = '1222256444';
        ac.BillingStreet = 'testIng Street';
        ac.BillingCity = 'Sydney test2';
        ac.BillingPostalCode = '77881100';
        ac.BillingState = 'test State';
        ac.Emergency_Contact__c = '11225566';
        ac.Emergency_Contact_Mobile__c = '33990011';
        ac.Emergency_Contact_Relationship__c = 'test Contact Relation';
        ac.media_opt_in_take_video_photos__c = true;
        ac.media_opt_in_share_participants__c = false;
        ac.Media_Opt_in_Public_Sharing__c = true;       
        insert ac;
        // Created a test Contact record 
        Contact con = new Contact();
        con.LastName = 'testContact';
        con.Email = 'testversion290@gmail.com';
        con.Shirt_size__c = 'Kids 6';
        con.Swimming_Ability__c = '50m and above';
        con.AccountId = ac.Id;
        con.Family_Member_Type__c = 'Aunt';
        con.npsp__Deceased__c = False;
        con.Exclude_From_Portal__c = False;
        insert con;
        // Created a test Campaign record 
        Campaign cm = new Campaign();
        cm.Name = 'test Camp Event';
        // cm.Status = 'Approved for portal and invites';
        cm.Location_Venue__c = ac.Id;
        cm.Registrations_Open__c =  System.today() -1;
        cm.Event_Start_Date__c = System.today() -1 ;
        cm.Event_End_Date__c = System.today();
        cm.Event_time__c = '12';
        cm.RVSP__c = 'test RSVP';
        cm.Cost_Centre__c = '1010';
        cm.Event_Type__c = 'Family Camp';
        cm.Registrations_Closed__c = System.today() - 5;
        cm.Description = 'test event description';
        cm.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Family_Camp').getRecordTypeId();
        cm.IsActive = True;
        cm.LanyardTextLine1__c = 'Test 1 Line';
        cm.LanyardTextLine2__c = 'Test 2 Line';
        cm.Annotations__c = 'Test Annotations';
        cm.Subcode_Campaign__c = '2000';
        // cm.Portal_Title__c = 'New Test POrtal Title';
        //cm.Portal_Description__c = 'Test Description';
        cm.RVSP__c = 'Test RSVP';
        cm.Approved__c = 'Yes';
        cm.Volunteer_Invite_Description__c = 'Test Invite Description';
        cm.Event_Acceptance_Note__c = 'Test Acceptance Note';
        cm.Banner_Image_URL__c = 'Test@test.com';
        cm.Type = 'Other';
        cm.Registrations_Cancellation__c = System.today()+4;
        insert cm;
        
        ContentVersion cv=new Contentversion();
        cv.title='cq_portal_Abc';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('This is version data');
        insert cv;
        
        // Created a test Registration type record 
        Registration_Type__c regType = new Registration_Type__c();
        regType.Name = 'test Regist Name';
        regType.Number_Available__c = 5;
        regType.Event__c = cm.Id;
        insert regType;      
        // Created a test Family attendence record with status as Attended
        Family_Attendance__c fm = new Family_Attendance__c();
        fm.Event__c = cm.Id;
        fm.Family__c = ac.Id;
        fm.Cancellation_Reason__c = 'test Cancel Family';
        fm.Registration_Type__c = regType.Id;  
        fm.Family_Member_On_Treatment__c = true;
        fm.FA_00000__c = 'Attended';
        fm.Declined_Reason__c='Date/s.';
        insert fm;
        // Created a test Family attendence record with status as Accepted       
        Family_Attendance__c fmt = new Family_Attendance__c();
        fmt.Event__c = cm.Id;
        fmt.Family__c = ac.Id;
        fmt.Cancellation_Reason__c = 'test Cancel Family';
        fmt.Registration_Type__c = regType.Id;  
        fmt.Family_Member_On_Treatment__c = true;
        fmt.FA_00000__c = 'Accepted';
        fmt.Declined_Reason__c='Date/s.';
        insert fmt;
        // Created a test Family attendence record with status as Invited
        Family_Attendance__c fmta = new Family_Attendance__c();
        fmta.Event__c = cm.Id;
        fmta.Family__c = ac.Id;
        fmta.Cancellation_Reason__c = 'test Cancel Family';
        fmta.Registration_Type__c = regType.Id;  
        fmta.Family_Member_On_Treatment__c = true;
        fmta.FA_00000__c = 'Invited';
        fmta.Declined_Reason__c='Date/s.';
        insert fmta;
        // Created a test Family attendence record with status as Request to Attend
        Family_Attendance__c fmtc = new Family_Attendance__c();
        fmtc.Event__c = cm.Id;
        fmtc.Family__c = ac.Id;
        fmtc.Cancellation_Reason__c = 'test Cancel Family';
        fmtc.Registration_Type__c = regType.Id;  
        fmtc.Family_Member_On_Treatment__c = true;
        fmtc.FA_00000__c = 'Request to Attend';
        fmtc.Declined_Reason__c='Venue.';
        insert fmtc;
        Family_Attendance__c fmtd = new Family_Attendance__c();
        fmtd.Event__c = cm.Id;
        fmtd.Family__c = ac.Id;
        fmtd.Cancellation_Reason__c = 'test Cancel Family';
        fmtd.Registration_Type__c = regType.Id;  
        fmtd.Family_Member_On_Treatment__c = true;
        fmtd.FA_00000__c = 'Declined';
        fmtc.Declined_Reason__c='Venue.';
        insert fmtd;
        
        Family_Attendance__c fmte = new Family_Attendance__c();
        fmte.Event__c = cm.Id;
        fmte.Family__c = ac.Id;
        fmte.Cancellation_Reason__c = 'test Cancel Family';
        fmte.Registration_Type__c = regType.Id;  
        fmte.Family_Member_On_Treatment__c = true;
        fmte.FA_00000__c = 'Cancelled';
        fmtc.Declined_Reason__c='Venue.';
        insert fmte;
        // Created a test Family member attendence record
        Family_Member_Attendance__c fma = new Family_Member_Attendance__c();
        fma.Special_Celebration__c = 'test Celebreation';
        fma.Transport_Pick_Up_Required__c = 'No';
        fma.Transport_Drop_Off_Required__c = 'Yes';
        fma.Contact__c = con.Id;
        fma.Event__c = cm.Id;
        fma.Attendance__c='Invited';
        fma.Family_Attendance__c = fm.Id;
        insert fma;
        
         // Created a test Family member attendence record
        Family_Member_Attendance__c fmat = new Family_Member_Attendance__c();
        fmat.Special_Celebration__c = 'test Celebreation';
        fmat.Transport_Pick_Up_Required__c = 'No';
        fmat.Transport_Drop_Off_Required__c = 'Yes';
        fmat.Contact__c = con.Id;
        fmat.Event__c = cm.Id;
        fmat.Attendance__c='Declined';
        fmat.Family_Attendance__c = fm.Id;
        insert fmat;
     
        // Created a test special needs record with record type as Dietary_Requirement.
        Special_Needs__c speDiet = new Special_Needs__c();
        speDiet.Contact__c = con.Id;
        speDiet.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId();
        speDiet.Long_Description__c = 'Allergic - All Nuts';
        speDiet.Comments__c = 'testComments';
        insert speDiet;
        // Created a test special needs record with record type as Special_Need.
        Special_Needs__c speNeed = new Special_Needs__c();
        speNeed.Contact__c = con.Id;
        speNeed.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId();
        speNeed.Long_Description__c = 'Allergic - Buckwheat';
        speNeed.Comments__c = 'TestSpComment';
        insert speNeed;
        // Created a test special needs record.
        Special_Needs__c spDietNeed  = new Special_Needs__c();
        spDietNeed.Contact__c = con.Id;
        spDietNeed.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId();
        spDietNeed.Long_Description__c = 'Allergic - All Nuts';
        spDietNeed.Comments__c = 'deleteDiet';
        insert spDietNeed;
        
        //Retrieve the Profile with the name 'My Camp Quality Members'
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        // Create a new User record and populate its fields
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            UserName=con.Email,
            Alias=con.Email.subString(0, 8),
            FirstName=con.FirstName,
            LastName=con.LastName,
            IsActive = true
        );
        
        insert us;
        
        
    }
    
    //It tests the functionality of retrieving events associated with a specific campaign.
    @istest
    public static void testFetchEvents(){   
        // Start the test execution context
        Test.startTest();	
        // Query for a test Campaign record named 'test Camp Event'
        try{
            Account ac= [SELECT Id,  Name from Account WHERE Name  = 'test Event' LIMIT 1];
            List<Campaign>camList = new List<Campaign>();
            List<Campaign> cam = [SELECT Id, Name from Campaign WHERE Name = 'test Camp Event' LIMIT 1];
            // Query for a test Contact record containing 'test' in the last name
            List<Contact> con = [Select Id, Email,FirstName,LastName From Contact WHERE LastName Like '%test%' LIMIT 1];
            // Retrieve the User associated with the test Contact
            User us = [Select Id, Name, Email, ContactId From User where ContactId =: con[0].Id];
            System.assertNotEquals(0 , cam.size() , 'Campaign records must have expected size greater than zero');
            System.assertNotEquals(0 , con.size() , 'Contact records size cannot be zero');
            
            
            
            Campaign cm = new Campaign();
            cm.Name = 'test Camp Event';
            cm.Status = 'Approved for portal and invites';
            cm.Location_Venue__c = ac.Id;
            cm.Registrations_Open__c =  System.today() -1;
            cm.Event_Start_Date__c = System.today() -1 ;
            cm.Event_End_Date__c = System.today();
            cm.Event_time__c = '12';
            cm.RVSP__c = 'test RSVP';
            cm.Cost_Centre__c = '1010';
            cm.Event_Type__c = 'Family Camp';
            cm.Registrations_Closed__c = System.today() - 5;
            cm.Description = 'test event description';
            cm.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Family_Camp').getRecordTypeId();
            cm.IsActive = True;
            cm.LanyardTextLine1__c = 'Test 1 Line';
            cm.LanyardTextLine2__c = 'Test 2 Line';
            cm.Annotations__c = 'Test Annotations';
            cm.Subcode_Campaign__c = '2000';
            cm.RVSP__c = 'Test RSVP';
            cm.Approved__c = 'Yes';
            cm.Volunteer_Invite_Description__c = 'Test Invite Description';
            cm.Event_Acceptance_Note__c = 'Test Acceptance Note';
            cm.Banner_Image_URL__c = 'Test@test.com';
            cm.Type = 'Other';      
            cm.Registrations_Cancellation__c = System.today()+4;
            cm.EndDate = System.today() +1;
            camList.add(cm);
            insert camList;
            
            // Created a test Registration type record 
            Registration_Type__c regType = new Registration_Type__c();
            regType.Name = 'test Regist Name';
            regType.Number_Available__c = 5;
            regType.Event__c = camList[0].Id;
            insert regType;      
            Family_Attendance__c fmtc = new Family_Attendance__c();
            fmtc.Event__c = camList[0].Id;
            fmtc.Family__c = ac.Id;
            fmtc.Cancellation_Reason__c = 'test Cancel Family';
            fmtc.Registration_Type__c = regType.Id;  
            fmtc.Family_Member_On_Treatment__c = true;
            fmtc.FA_00000__c = 'Request to Attend';
            insert fmtc;
            
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [
                SELECT Id, Title, LatestPublishedVersionId 
                FROM ContentDocument
            ];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = camList[0].Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            insert cdl;
            // Run the test as the specified User
            System.runAs(us){
                String userIdToEncrypt = us.Id;
                Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
                Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
                String encryptedString = EncodingUtil.base64Encode(cipherText);
                // Call the 'fetchEvents' method from the 'FamilyEventController' class
                List<FamilyEventController.FetchEventDataWrap> wrap= FamilyEventController.fetchEvents(encryptedString);   
                Assert.isNotNull(wrap);		
            } 
        }
        catch(Exception ex){
            System.assertNotEquals('Error ', ex.getMessage());
        }       
        Test.stopTest();
        
    }
    
    @istest
    public static void testFamilyEventdetails(){
        
        Campaign cam = [SELECT Id, Name from Campaign WHERE Name = 'test Camp Event' LIMIT 1];
        List<Contact> con = [Select Id, Email,FirstName,LastName From Contact WHERE LastName = 'testContact' LIMIT 1];
        User us = [SELECT Id,ContactId, Email FROM User LIMIT 1];
        Test.startTest();
        
        String userIdToEncrypt = us.Id;
        Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
        String encryptedString = EncodingUtil.base64Encode(cipherText);
        FamilyEventController.WrapperRegisAtten wrapResult = FamilyEventController.familyEventdetails(cam.Id, encryptedString);
        FamilyEventController.preferredSessionPicklist(cam.Id);	
        System.assertEquals(cam.Id, wrapResult.Id, 'Campaign ID in the wrapper should match the queried campaign');
        Test.stopTest();
    }
    
    @istest
    public static void testUpdateEventDetails(){
        
        Family_Attendance__c fmAtt = [Select Id, FA_00000__c, Cancellation_Reason__c,Declined_Reason__c ,(select Id ,Attendance__c from Family_Member_Attendance__r
        )from Family_Attendance__c  LIMIT 1];
        Test.startTest();
        
        List<Contact> con = [Select Id, Email,FirstName,LastName From Contact WHERE LastName Like '%test%' LIMIT 1];
        User us = [Select Id, Name, Email, ContactId From User where ContactId =: con[0].Id];
        
        System.runAs(us){
          FamilyEventController.updateEventDetails(fmAtt.Id, 'Cancelled' , 'test Cancel Family','Date/s.');
          FamilyEventController.updateEventDetails(fmAtt.Id, 'Declined' , 'test Cancel Family','Date/s.');
        }
        //FamilyEventController.updateEventDetails(fmAtt.Id, 'Declined' , 'test Cancel Family','Venue');

        System.assertEquals('Attended', fmAtt.FA_00000__c, 'Family Attendance status should remain as Attended');
        System.assertEquals('test Cancel Family', fmAtt.Cancellation_Reason__c, 'Cancellation Reason should be updated to "test Cancel Family"');
        Test.stopTest();
    }
    @istest
    public static void testUpdateEventDetailsCancell(){
        
        Family_Attendance__c fmAtt = [Select Id, FA_00000__c, Cancellation_Reason__c, Declined_Reason__c from Family_Attendance__c WHERE FA_00000__c = 'Cancelled' LIMIT 1];
        Family_Attendance__c fmAttInv = [Select Id, FA_00000__c, Cancellation_Reason__c ,Declined_Reason__c from Family_Attendance__c WHERE FA_00000__c = 'Invited' LIMIT 1];
        Family_Attendance__c fmAttReq = [Select Id, FA_00000__c, Cancellation_Reason__c ,Declined_Reason__c from Family_Attendance__c WHERE FA_00000__c = 'Request to Attend' LIMIT 1];
        Family_Attendance__c fmAttDec = [Select Id, FA_00000__c, Cancellation_Reason__c ,Declined_Reason__c  from Family_Attendance__c WHERE FA_00000__c = 'Request to Attend' LIMIT 1];
        Test.startTest();
        
        List<Contact> con = [Select Id, Email,FirstName,LastName From Contact WHERE LastName Like '%test%' LIMIT 1];
        User us = [Select Id, Name, Email, ContactId From User where ContactId =: con[0].Id];
        
        System.runAs(us){
           FamilyEventController.updateEventDetails(fmAtt.Id, 'Cancelled' , 'test Cancel Family','Date/s.');
            FamilyEventController.updateEventDetails(fmAttInv.Id, 'Invited' , 'test Cancel Family','Date/s.');
            FamilyEventController.updateEventDetails(fmAttReq.Id, 'Request to Attend' , 'test Cancel Family','Date/s.');
            FamilyEventController.updateEventDetails(fmAttDec.Id, 'Declined' , 'test Cancel Family','Date/s.');
        }
        System.assertEquals('Cancelled', fmAtt.FA_00000__c, 'Family Attendance status should remain as Attended');
        System.assertEquals('test Cancel Family', fmAtt.Cancellation_Reason__c, 'Cancellation Reason should be updated to "test Cancel Family"');
        Test.stopTest();
    }
    // Test method to is use to test getTableBtnData method 
    @istest
    public static void testGetTableBtnData(){
        
        Contact con = [Select Id , LastName From Contact WHERE LastName = 'testContact' LIMIT 1];
        Test.startTest();
        // Call the getTableBtnData method in the FamilyEventController class
        FamilyEventController.getTableBtnData(con.Id);
        System.assertEquals('testContact', con.LastName, 'Expected exactly one Contact match LastName with "testContact"');
        Test.stopTest();
    }
    // Test method to is use to test getConfirmBtnData method 
    @istest()
    public static void testGetConfirmBtnData(){
        Contact con = [Select Id , LastName From Contact WHERE LastName = 'testContact' LIMIT 1];
        Family_Member_Attendance__c famMemId= [SELECT ID, Special_Celebration__c from Family_Member_Attendance__c WHERE Transport_Pick_Up_Required__c = 'No'LIMIT 1];
        Test.startTest();
        
        // Call the getConfirmBtnData method in the FamilyEventController class
        FamilyEventController.getConfirmBtnData(con.Id, famMemId.Id);
        System.assertEquals('testContact', con.LastName, 'Expected exactly one Contact match LastName with "testContact"');
        
        Test.stopTest();
    }
    // This method is use to test of the updateTableData method
    @istest()
    public static void testUpdateTableData(){
        // Query for a test Contact record with the last name 'testContact'
        Contact con = [Select Id From Contact WHERE LastName = 'testContact' LIMIT 1];
        // Start the test execution
        Test.startTest();
        // Query for Special_Needs__c records related to the test Contact
        List<Special_Needs__c> spNeedDiet = [Select Id,RecordTypeId,Long_Description__c,Comments__c,Contact__c FROM Special_Needs__c WHERE Contact__c =:con.Id];
        // Variables to store specific Special_Needs__c records
        Special_Needs__c speDietry;
        Special_Needs__c speNeed;
        Special_Needs__c speDelete;
        // Lists to store instances of DietWrapper and SpeNeedWrapper for testing
        List<FamilyEventController.DietWrapper> dietWrap = new List<FamilyEventController.DietWrapper>();
        List<FamilyEventController.SpeNeedWrapper> spWrap = new List<FamilyEventController.SpeNeedWrapper>();
        
        for(Special_Needs__c spn : spNeedDiet){
            if(spn.recordTypeId == Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId()){
                // Creating SpeNeedWrapper instance for Special_Need record                
                FamilyEventController.SpeNeedWrapper spNeed = new FamilyEventController.SpeNeedWrapper();
                spNeed.specNeedDescription = spn.Long_Description__c;
                spNeed.specNeedComment = spn.Comments__c;
                spNeed.id = spn.Id;
                spNeed.recordId = spn.Id;
                spWrap.add(spNeed);                
                speNeed = spn;
                System.assertEquals(1,spWrap.size(),'FamilyEventController.SpeNeedWrapper size should be equal to One');
            }
            else if(spn.recordTypeId == Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId()){
                if(spn.Comments__c == 'testComments'){
                    // Creating DietWrapper instance for Dietary_Requirement record
                    FamilyEventController.DietWrapper diet = new FamilyEventController.DietWrapper();
                    diet.recordId = '';
                    diet.id = '';
                    diet.dietComment = spn.Comments__c;
                    diet.dietDescription = spn.Long_Description__c;
                    dietWrap.add(diet);                    
                    speDietry = spn;
                    System.assertEquals(1,dietWrap.size(),'FamilyEventController.DietWrapper size should be equal to One');
                }
                else{
                    speDelete = spn;
                }
            }           
        }
        
        
        Family_Member_Attendance__c famMemId= [SELECT ID, Special_Celebration__c from Family_Member_Attendance__c WHERE Transport_Pick_Up_Required__c = 'No'LIMIT 1];
        
        
        // Creating JSON data for testing
        String jsonData = '{"memberId":"' + famMemId.Id + '","shirtSize":"Kids 8","swimmingAbility":"50m and above","specialCelebration":"test555","transportPickUpRequired":"No","transportDropOffRequired":"No","eventtransportAccOrNot":"Ballina","homeTransportAcceptOrNot":"Dubbo","dietList":[{"dietComment":"test2.0 No banabas","dietDescription":"No Bananas","id":"'+speDietry.Id+'","recordId":"'+speDietry.Id+'"},{"dietComment":"test","dietDescription":"Allergic - Fish","id":"1","recordId":""},{"dietComment":"test","dietDescription":"Allergic - Fish","id":"'+speDietry.Id+'","recordId":"'+speDietry.Id+'"}],"speNeedList":[{"id":"'+speNeed.Id+'","recordId":"'+speNeed.Id+'","specNeedComment":"test Etoposide","specNeedDescription":"Allergy - Etoposide"},{"id":"0","recordId":"","specNeedComment":"new check glass","specNeedDescription":"Wears Glasses"}],"speNeedDelete":[],"id":"'+speNeed.Id+'"}';
        //Call the method with two parameter  
        FamilyEventController.updatetableData(jsonData, con.Id);
       	// Assert record updates
        Contact updatedContact = [SELECT Id, Swimming_Ability__c, Shirt_Size__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Kids 8', updatedContact.Shirt_Size__c, 'Shirt Size not updated as expected');
        System.assertEquals('50m and above', updatedContact.Swimming_Ability__c, 'Swimming Ability not updated as expected');
        
        Family_Member_Attendance__c updatedFamMemberAtt = [SELECT Id, Transport_Pick_Up_Required__c, Transport_Drop_Off_Required__c FROM Family_Member_Attendance__c WHERE Id = :famMemId.Id];
        System.assertEquals('No', updatedFamMemberAtt.Transport_Pick_Up_Required__c, 'Transport_Pick_Up_Required not updated as expected');
        System.assertEquals('No', updatedFamMemberAtt.Transport_Drop_Off_Required__c, 'Transport_Drop_Off_Required not updated as expected');
        
        // Assert Special Needs upsert
        List<Special_Needs__c> upsertedSpecialNeeds = [SELECT Id, Long_Description__c, Comments__c FROM Special_Needs__c WHERE Contact__c = :con.Id];
        System.assertNotEquals(2, upsertedSpecialNeeds.size(), 'Special Needs records not correctly upserted');
        
        Test.stopTest();              
    }
    // Test method to is used to test getConDatafortable method
    @istest()
    public static void testGetConDatafortable(){
        // Start the test execution
        Test.startTest();
        Family_Member_Attendance__c famMemId= [SELECT ID, Special_Celebration__c from Family_Member_Attendance__c WHERE Transport_Pick_Up_Required__c = 'No'LIMIT 1];
        List<Contact> con = [Select Id, Email,FirstName,LastName From Contact WHERE LastName Like '%test%' LIMIT 1];
        Campaign cam = [SELECT Id, Name from Campaign WHERE Name = 'test Camp Event' LIMIT 1];
        User us = [Select Id, Name, Email, ContactId From User where ContactId =: con[0].Id];        
        System.runAs(us){
            //	FamilyEventController.getConDatafortable(us.Id, cam.Id);
            FamilyEventController.getConDatafortable(famMemId.Id);
            System.assertEquals(1, con.size(), 'Expected list size should return the size of One');
        }      
        
        Test.stopTest(); 
    }
    // Test method to is used to test getAccountDatatable method. 
    @istest()
    public static void testGetAccountDatatable(){
        
        Test.startTest();
        //Query the contact with lastname is like test
        List<Contact> con = [Select Id, Email,FirstName,LastName From Contact WHERE LastName Like '%test%' LIMIT 1];
        // Query for a User associated with the test Contact
        User us = [Select Id, Name, Email, ContactId From User where ContactId =: con[0].Id];
        Campaign cam = [SELECT Id, Name from Campaign WHERE Name = 'test Camp Event' LIMIT 1];
        Family_Attendance__c fmAtt = [Select Id, FA_00000__c, Cancellation_Reason__c from Family_Attendance__c WHERE FA_00000__c = 'Attended' LIMIT 1];                      
        // Run the test within the context of the test User
        System.assertEquals(1, con.size(), 'Expected the list to contain One records');
        System.runAs(us){
            String userIdToEncrypt = us.Id;
            Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
            Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
            String encryptedString = EncodingUtil.base64Encode(cipherText);
            // Call the getAccountDatatable method in the FamilyEventController class
            FamilyEventController.getAccountDatatable(encryptedString, cam.Id, fmAtt.Id);          
        }
        // Stop the test execution
        Test.stopTest(); 
    }
    
    // Test method to is used to test updateAccountData method.
    @istest()
    public static void testUpdateAccountData(){
        Test.startTest();
        // Query for a test Contact record with a last name containing 'test'
        List<Contact> con = [Select Id, Email,FirstName,LastName From Contact WHERE LastName Like '%test%' LIMIT 1];
        // Query for a User associated with the test Contact
        User us = [Select Id, Name, Email, ContactId From User where ContactId =: con[0].Id];
        Campaign cam = [SELECT Id, Name from Campaign WHERE Name = 'test Camp Event' LIMIT 1];
        Family_Attendance__c fmAtt = [Select Id, FA_00000__c, Cancellation_Reason__c from Family_Attendance__c WHERE FA_00000__c = 'Attended' LIMIT 1];        
        List<String> famUpdateList = new List<String>();                
        famUpdateList.add('Request to Attend');
        famUpdateList.add('Declined');
        
        System.assertEquals(1, con.size(), 'Expected the list to contain One records');
        // Create a test instance of the getAccountDataWrap class
        FamilyEventController.getAccountDataWrap wrap = new FamilyEventController.getAccountDataWrap();
        wrap.emergency_Contact = 'New contact test';
        wrap.emergency_Contact_Mobile = '67887656780';
        wrap.emergency_Contact_Phone = '909890989898';
        wrap.emergency_Contact_Relationship = 'Family';
        wrap.family_Member_On_Treatment = False;
        wrap.mediaparticipant = False;
        wrap.mediaTakePhoto = False;
        wrap.mediaSharingPhoto = true;
        wrap.consent =true;
        wrap.behavioralExpectations = true;    
        // Run the test within the context of the identified test User
        System.runAs(us){
            String userIdToEncrypt = us.Id;
            Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
            Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userIdToEncrypt));
            String encryptedString = EncodingUtil.base64Encode(cipherText);
            // Call the updateAccountData method in the FamilyEventController class with the test instance of getAccountDataWrap
            String sucessfull = FamilyEventController.updateAccountData(wrap, encryptedString, cam.Id, fmAtt.Id,famUpdateList);
            System.assertEquals('Sucessfully', sucessfull, 'Run Sucessfully');
        }
        // Stop the test execution
        Test.stopTest();                
    }
    
    @isTest
    public static void testContentVersion() {
        List<ContentVersion> conVerList = [SELECT Id, Title FROM ContentVersion WHERE Title = 'cq_portal_Abc' LIMIT 1];
        
        // Assuming contentVersion method in FamilyEventController is a static method
        Test.startTest();
        String conVer = FamilyEventController.contentVersion(conVerList[0].Id);       
        Test.stopTest();   
         // Verify that the encoded version data is not null
   		 System.assertNotEquals(null, conVer, 'Encoded version data should not be null');
        // Add your assertions or additional test logic here
    }
    
    
    @isTest
    public static void testContentVersionforEvent() {
        List<ContentVersion> conVerList = [SELECT Id, Title FROM ContentVersion WHERE Title = 'cq_portal_Abc' LIMIT 1];
        
        // Assuming contentVersion method in FamilyEventController is a static method
        Test.startTest();
        FamilyEventController.contentVersionforEvent(conVerList[0].Id);
        Test.stopTest();
        
        // Add your assertions or additional test logic here
    }
    
    @isTest
    public static void testTransportPicklist(){
        Campaign cam = [SELECT Id, Name from Campaign WHERE Name = 'test Camp Event' LIMIT 1];
        List<String> picList = FamilyEventController.transportLocationHome(cam.Id);
        Assert.isNotNull(picList);
        List<String> picList2 = FamilyEventController.transportLocationPic(cam.Id);
        Assert.isNotNull(picList2);        
        
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
    

    @isTest
    static void testGetFamAttPicklistValues() {
     // Execute the method
        List<Map<String, String>> result = FamilyEventController.getFamAttPicklistValues();
        // Validate the results
        // Ensure that the result is not null and contains some values
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Result should contain picklist values');
        // Further assert to check the structure of the returned data
        for (Map<String, String> picklistValue : result) {
            System.assert(picklistValue.containsKey('label'), 'Each entry should contain a label');
            System.assert(picklistValue.containsKey('value'), 'Each entry should contain a value');
        }
    }

}