@isTest 
private class MatchChildControllerTest {

    static testMethod  void testChildController() {
     
		Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'Campaign Name' LIMIT 1];

        
       PageReference pageRef = Page.MatchChild;
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);
        
        
        MatchChildController obj  = new MatchChildController(sc);
		obj.getListOfVolunteers();
        obj.setAttendeds();
        obj.matchVolunteer();        
    }
	@testSetup static void SetupTests() {
           Map<String, RecordType> rMapRtype = new Map<String, RecordType>();
        Map<String, RecordType> rMap = new Map<String, RecordType>();
                Map<String, RecordType> aMap = new Map<String, RecordType>();
                Map<String, RecordType> cMap = new Map<String, RecordType>();

      //for(RecordType r : [SELECT Id, DeveloperName FROM RecordType where SobjectType = 'Registration_Type__C'])
        //    rMapRType.put(r.DeveloperName, r);
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType where SobjectType = 'Campaign'])
            rMap.put(r.DeveloperName, r);
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType where SobjectType = 'Account'])
            aMap.put(r.DeveloperName, r);
      for(RecordType r : [SELECT Id, DeveloperName FROM RecordType where SobjectType = 'Contact'])
            cMap.put(r.DeveloperName, r);
      
        Account a = New Account( Name = 'Family', RecordTypeId = aMap.get('Family').Id );
        insert a;

        Contact vol = new Contact( AccountId = a.Id, FirstName = 'Dad', LastName = 'Family', Volunteer_Eligibility__c  = 'Currently Eligible', Date_From__c = System.Today().addMonths(-6), RecordTypeId = cMap.get('Volunteer').Id );
        insert vol; 
        
        Contact fm1 = new Contact( FirstName = 'Dad', LastName = 'Family', Family_Member_Type__c = 'Father', AccountId = a.Id, RecordTypeId = cMap.get('Family_Member').Id );
        insert fm1;
        
        Contact fm2 = new Contact( FirstName = 'Sibling', LastName = 'Family', Family_Member_Type__c = 'Brother', AccountId = a.Id, RecordTypeId = cMap.get('Family_Member').Id );
        insert fm2;
        
          
        Campaign cam = new Campaign( Name = 'Campaign Name', isActive = true, RecordTypeId = rMap.get('Age_Camp').Id );
        Insert cam;
        
        
        
        //Registration_Type__c rt = new Registration_Type__c( Name = 'Jnr Camp', Event__c = cam.Id, Ticket_Type__c = 'Jnr Camp', RecordTypeId = rMapRType.get('Aged_Camp').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        //insert rt;
        Family_Attendance__c fa = new Family_Attendance__c(Family__c = a.Id, Event__c = cam.Id, FA_00000__c = 'Accepted');

        insert fa;
        Family_Member_Attendance__c fma1 = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Accepted', Family_Attendance__c = fa.Id, Contact__c = fm1.Id);
        insert fma1;
                Family_Member_Attendance__c fma2 = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Accepted', Family_Attendance__c = fa.Id, Contact__c = fm2.Id);
        insert fma2;
          //      Family_Member_Attendance__c fma3 = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Accepted', Family_Attendance__c = fa.Id, Contact__c = fm3.Id);
   
        Volunteer_Attendance__c va = new Volunteer_Attendance__c(Event__c = cam.Id, Attendance__c = 'Accepted', Volunteer__c = vol.Id);

        insert va;
               
    }


}