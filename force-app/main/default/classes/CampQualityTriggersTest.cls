@isTest
private class CampQualityTriggersTest {
    
     @testSetup static void SetupTests() {
		     
         
         
     }
    
    @isTest static void TestTriggers1() {
          Account ac = new Account(name ='Test Account') ;
        insert ac; 

        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,npsp__Deceased__c = false, Exclude_From_Portal__c = false);
        insert con;   
           Campaign cmp = new Campaign(Name = 'Campaign Name', Status = 'Planned', isActive = true, Registrations_Open__c = (Datetime.now() - 1), Registrations_Closed__c = (Datetime.now() + 1) );

        insert cmp;
        
        Special_Needs__c sn = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = con.Id, Long_Description__c = 'Allergic - Garlic');

        insert sn;

        List<Volunteer_Checklist__c> vcs = new List<Volunteer_Checklist__c>{
        	new Volunteer_Checklist__c(Volunteer_Check_List__c = 'Code of Conduct Form', Date_Completed__c = Date.today(), Volunteer__c = con.Id),
        	new Volunteer_Checklist__c(Volunteer_Check_List__c = 'Volunteer References', Date_Completed__c = Date.today(), Volunteer__c = con.Id),
        	new Volunteer_Checklist__c(Volunteer_Check_List__c = 'Volunteer Interview', Date_Completed__c = Date.today(), Volunteer__c = con.Id),
        	new Volunteer_Checklist__c(Volunteer_Check_List__c = 'Photo ID Sighted', Date_Completed__c = Date.today(), Volunteer__c = con.Id) 
        };

        insert vcs;

        Volunteer_Skill__c vs = new Volunteer_Skill__c(License__c = 'Test License', License_No__c = '1234567', Volunteer__c = con.Id);

        insert vs;

        Volunteer_Course__c vc = new Volunteer_Course__c(Volunteer__c = con.Id, Course__c = 'Medical Volunteer Induction', Course_Date__c = Date.today());

        insert vc;
        delete vc;

        Site__c site = new Site__c(Name = 'Volunteer Portal');

        insert site;

        Page__c page = new Page__c(Name = 'Volunteer My Events', Site__c = site.Id);

        insert page;

        Page__c page2 = new Page__c(Name = 'Volunteer Event', Site__c = site.Id);

        insert page2;

        ContentVersion contentVersion_1 = new ContentVersion(
              Title = 'Penguins',
              PathOnClient = 'Penguins.jpg',
              VersionData = Blob.valueOf('Test Content'),
              IsMajorVersion = true
        );
        insert contentVersion_1;
            
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = documents[0].Id, LinkedEntityId = cmp.Id, ShareType = 'V', Visibility = 'AllUsers');

        insert cdl;

        System.debug('cdl: ' + cdl);

        
    }
        @isTest static void TestTriggers2() {
        	Id p = [select id from profile where name='My Camp Quality Members'].id;

          Account ac = new Account(name ='Test Account') ;
        insert ac; 

        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,npsp__Deceased__c = false, Exclude_From_Portal__c = false);
        insert con;    
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        		                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
        		                ContactId = con.Id, timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert user;
        Campaign cmp = new Campaign(Name = 'Campaign Name', Status = 'Planned', isActive = true, Registrations_Open__c = (Datetime.now() - 1), Registrations_Closed__c = (Datetime.now() + 1) );

        insert cmp;

        Registration_Type__c rt = new Registration_Type__c(Name = 'Test Registration', Number_Available__c = 10, Event__c = cmp.Id);

        insert rt;

        Session__c session = new Session__c(Name = 'Test Session', Event__c = cmp.Id, Volunteers_Required__c = 20);

        insert session;

        Volunteer_Attendance__c va = new Volunteer_Attendance__c(Event__c = cmp.Id, Attendance__c = 'Invited', Volunteer__c = con.Id, Registration_Type__c = rt.Id);

        insert va;

        va = new Volunteer_Attendance__c(Event__c = cmp.Id, Attendance__c = 'Accepted', Volunteer__c = con.Id, Registration_Type__c = rt.Id);

        insert va;

        Session_Participant__c sp = new Session_Participant__c(Session__c = session.Id, Volunteer_Attendance__c = va.Id, Volunteer_Contact__c = con.Id);

        insert sp;

        Family_Attendance__c fa = new Family_Attendance__c(Family__c = ac.Id, Event__c = cmp.Id, FA_00000__c = 'Request to Attend', Registration_Type__c = rt.Id);

        insert fa;

        fa.FA_00000__c = 'Attended';

        update fa;

        Family_Member_Attendance__c fma = new Family_Member_Attendance__c(Event__c = cmp.Id, Attendance__c = 'Request to Attend', Family_Attendance__c = fa.Id, Contact__c = con.Id);

        insert fma;


        Transport__c trans = new Transport__c(Event__c = cmp.Id, Capacity__c = 10);

        insert trans;

        Transport_Participant__c tp = new Transport_Participant__c(Contact__c = con.Id, Transport__c = trans.Id, Volunteer_Attendance__c = va.Id);

        insert tp;
            
        Registration_Period__c rp = new Registration_Period__c(Name = 'Period', Campaign__c = cmp.Id, Number_Available__c = 50, Start_Date__c = Date.today(), End_Date__c = Date.today());
        
        insert rp;
        
        Registration_Type_Period__c rtp = new Registration_Type_Period__c(Registration_Type__c = rt.Id, Registration_Period__c = rp.Id);
        
        insert rtp;
        Registration_Period_Family_Attendance__c rpfa = new Registration_Period_Family_Attendance__c(Family_Attendance__c = fa.Id, Registration_Period__c= rp.Id);
              
        insert rpfa;
        
        Registration_Period_Volunteer_Attendance__c rpva = new Registration_Period_Volunteer_Attendance__c (Volunteer_Attendance__C = va.Id, Registration_Period__c= rp.Id );
        insert rpva;
            
        delete rpfa;
        delete rpva;
            
            //Registration_Period_Family_Attendance__c
              // Registration_Period_Volunteer_Attendance__c 

        }
	
}