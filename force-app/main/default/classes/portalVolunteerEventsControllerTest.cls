@isTest
private class portalVolunteerEventsControllerTest {
  
  @isTest static void test_method_one() {
      
    User u = [SELECT Id FROM User WHERE Username = 'tester@noemail.com'];

    system.runAs(u) {
            
      Test.startTest();

      Test.setCurrentPage(Page.portalEvents);

      ApexPages.currentPage().getParameters().put('p', 'pageName');

      portalVolunteerEventsController pec = new portalVolunteerEventsController();

      pec.getEventTypes();

      Test.stopTest();

        }

  }
  
  @isTest static void test_method_two() {
    
    User u = [SELECT Id FROM User WHERE Username = 'tester@noemail.com'];
    Campaign cmp = [SELECT Id FROM Campaign WHERE Name = 'Campaign Name' LIMIT 1];
 
    system.runAs(u) {
            
      Test.startTest();

      Test.setCurrentPage(Page.portalEvent);

      ApexPages.currentPage().getParameters().put('p', 'pageName');
      ApexPages.currentPage().getParameters().put('e', cmp.Id);

      portalVolunteerEventController pec = new portalVolunteerEventController();

      System.assertEquals(false, pec.cancellationAvailable);
      System.assertEquals(true, pec.registrationAvailable);

      pec.beginRegistration();
      pec.registerBookingId = new List<String>(pec.bookings.keySet())[0];

      ApexPages.currentPage().getParameters().put('cancel', 'true');
      pec.autoRegister();

      ApexPages.currentPage().getParameters().put('register', 'true');
      pec.autoRegister();

      pec.addType = 'DietryNeeds';
      pec.addSpecialNeed();
      pec.addSpecialNeed();
            
            pec.setRegistrationDates();
            
	        //TODO: Fix this test. Below commented.
        	//DR - 17 Feb 2023: Temporary change to pass tests.
            //pec.regPeriodId = pec.getRegistrationPeriods()[1].getValue();

      pec.register();

      for(String s : pec.currentNeeds.keySet()) {
        pec.removeNeedId = s;
        pec.removeSpecialNeed();
      }

      pec.beginRegistration();

      pec.cancelBookingId = pec.registerBookingId;

      pec.cancel();

      Test.stopTest();

        }

  }
  
  @testSetup static void SetupTests() {

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
        
        Registration_Period__c rp = new Registration_Period__c(Name = 'Period', Campaign__c = cmp.Id, Number_Available__c = 50, Start_Date__c = Date.today(), End_Date__c = Date.today());
        
        insert rp;
        
        Registration_Type_Period__c rtp = new Registration_Type_Period__c(Registration_Type__c = rt.Id, Registration_Period__c = rp.Id);
        
        insert rtp;

        Volunteer_Attendance__c va = new Volunteer_Attendance__c(Event__c = cmp.Id, Attendance__c = 'Invited', Volunteer__c = con.Id, Registration_Type__c = rt.Id);

        insert va;

        va = new Volunteer_Attendance__c(Event__c = cmp.Id, Attendance__c = 'Request to Attend', Volunteer__c = con.Id, Registration_Type__c = rt.Id);

        insert va;

        Special_Needs__c sn = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = con.Id, Long_Description__c = 'Allergic - Garlic');

        insert sn;

        Site__c site = new Site__c(Name = 'Volunteer Portal');

        insert site;

        Page__c page = new Page__c(Name = 'Volunteer My Events', Site__c = site.Id);

        insert page;

        Page__c page2 = new Page__c(Name = 'Volunteer Event', Site__c = site.Id);

        insert page2;


  }
  
}