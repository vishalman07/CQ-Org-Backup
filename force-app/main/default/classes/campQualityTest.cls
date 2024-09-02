@isTest(SeeAllData=false)
public class campQualityTest {
    
    
    static testMethod void testCampQUalityattendanceStatusEquivalent () {
        test.startTest();
        string a = '';
        a =    campQuality.attendanceStatusEquivalent('Invited');
        a =    campQuality.attendanceStatusEquivalent('Request to Attend');
        a =    campQuality.attendanceStatusEquivalent('Acceptance to be Sent');
        a =    campQuality.attendanceStatusEquivalent('Accepted');
        a =    campQuality.attendanceStatusEquivalent('Attended');
        a =    campQuality.attendanceStatusEquivalent('Declined');
        a =    campQuality.attendanceStatusEquivalent('Unsuccessful');
        a =    campQuality.attendanceStatusEquivalent('Cancelled');
        
        test.stopTest();
        
    }
    
    static testmethod void familyrollup() {
        Map<String, RecordType> rMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType])
            rMap.put(r.DeveloperName, r);
        Account a = New Account( Name = 'Family', RecordTypeId = rMap.get('Family').Id, Family_Type__c = 'Patient',Regionv2__c='ACT - Albury', Preferred_Event_Locations__c='Sydney', Family_Interests__c = 'Sports');
        insert a;
        
        Contact fm1 = new Contact( FirstName = 'Dad', LastName = 'Family', Family_Member_Type__c = 'Father', AccountId = a.Id, RecordTypeId = rMap.get('Family_Member').Id );
        insert fm1;
        
        Campaign cam = new Campaign( Name = 'Campaign Name', startdate=system.date.today().addDays(-10),isActive = true, RecordTypeId = rMap.get('Family_Camp').Id );
        Insert cam;
        
        Registration_Type__c rt = new Registration_Type__c( Name = 'Ticket', Event__c = cam.Id, Ticket_Type__c = 'Family', RecordTypeId = rMap.get('Ticket').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        insert rt;
        
        Family_Attendance__c fa = new Family_Attendance__c(Family__c = a.Id, Event__c = cAM.Id, FA_00000__c = 'Attended', Registration_Type__c = rt.Id);
        
        insert fa;
        Family_Member_Attendance__c fma = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Attended', Family_Attendance__c = fa.Id, Contact__c = fm1.Id);
        
        insert fma;
        Set<id> aSet = new set<id>();
        aSet.add(a.id);
        
        test.startTest();
        campquality.attendanceRollup(aSet);
        
        test.stopTest();
        
        
    }
    static testmethod void testfamilyMemberAttendanceUpdate1() {
        
        Map<String, RecordType> rMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType])
            rMap.put(r.DeveloperName, r);
        Account a = New Account( Name = 'Family', RecordTypeId = rMap.get('Family').Id, Family_Type__c = 'Patient',Regionv2__c='ACT - Albury', Preferred_Event_Locations__c='Sydney', Family_Interests__c = 'Sports');
        insert a;
        
        Contact fm1 = new Contact( FirstName = 'Dad', LastName = 'Family', Family_Member_Type__c = 'Father', AccountId = a.Id, RecordTypeId = rMap.get('Family_Member').Id );
        insert fm1;
        
        
        Contact fm2 = new Contact( FirstName = 'Sibling', LastName = 'Family', Family_Member_Type__c = 'Brother', AccountId = a.Id, RecordTypeId = rMap.get('Family_Member').Id );
        insert fm2;
        
        
        
        Campaign cam = new Campaign( Name = 'Campaign Name', isActive = true, RecordTypeId = rMap.get('Family_Camp').Id );
        Insert cam;
        
        Registration_Type__c rt = new Registration_Type__c( Name = 'Ticket', Event__c = cam.Id, Ticket_Type__c = 'Family', RecordTypeId = rMap.get('Ticket').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        insert rt;
        
        Family_Attendance__c fa = new Family_Attendance__c(Family__c = a.Id, Event__c = cAM.Id, FA_00000__c = 'Request to Attend', Registration_Type__c = rt.Id);
        
        insert fa;
        Family_Member_Attendance__c fma = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Invited', Family_Attendance__c = fa.Id, Contact__c = fm1.Id);
        
        insert fma;
        fma = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Request To Attend', Family_Attendance__c = fa.Id, Contact__c = fm2.Id);
        insert fma;
        
        fma.Attendance__c = 'Declined';
        update fma;
        fma.Attendance__c = 'Accepted';
        update fma;
        
        
        Set<id> faset = new set<id>();
        faset.add(fa.id);
        
        List<Family_Attendance__c> falist = new list<Family_Attendance__c>();
        falist.add(fa);
        
        Test.startTest();
        Campquality.familyAttendanceUpdate(faSet);
        campquality.familtAttendanceCampaignMember(faset);
        campquality.familtAttendanceCampaignMember(faset);
        campquality.familyMemberAttendance(falist);       
        campquality.familyMemberAttendanceUpdate(faset);
        test.stoptest();
        
        
    }
    
    
    static testMethod void testFamilyInviationFamily() {
        
        
        Map<String, RecordType> rMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType])
            rMap.put(r.DeveloperName, r);
        
        
        Account a = New Account( Name = 'Family', RecordTypeId = rMap.get('Family').Id, Family_Type__c = 'Patient',Regionv2__c='ACT - Albury', Preferred_Event_Locations__c='Sydney', Family_Interests__c = 'Sports');
        insert a;
        
        Contact fm1 = new Contact( FirstName = 'Dad', LastName = 'Family', Family_Member_Type__c = 'Father', AccountId = a.Id, RecordTypeId = rMap.get('Family_Member').Id );
        insert fm1;
        
        Contact fm2 = new Contact( FirstName = 'Sibling', LastName = 'Family', Family_Member_Type__c = 'Brother', AccountId = a.Id, RecordTypeId = rMap.get('Family_Member').Id );
        insert fm2;
        
        Contact fm3 = new Contact( FirstName = 'Patient', LastName = 'Family', Family_Member_Type__c = 'Patient', AccountId = a.Id, BirthDate = System.Today().addYears(-7), RecordTypeId = rMap.get('Family_Member').Id );
        insert fm3;
        
        Campaign cam = new Campaign( Name = 'Campaign Name', isActive = true, RecordTypeId = rMap.get('Family_Camp').Id );
        Insert cam;
        
        Registration_Type__c rt = new Registration_Type__c( Name = 'Ticket', Event__c = cam.Id, Ticket_Type__c = 'Family', RecordTypeId = rMap.get('Ticket').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        insert rt;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.FamilyInvitations);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);
        
        FamilyInvitationsController obj = new FamilyInvitationsController(sc);
        
        obj.getRegistrationTypes();
        
        //Family Picklist
        obj.getAttendanceValues();
        obj.getFamilyTypes();
        obj.getRegions();
        obj.getInterests();
        obj.getLocations();
        obj.getPreferredLocations();
        obj.selectedFamilyType = new List<String>{'Patient'};
            obj.selectedAttendance = new List<String>{'--None--'};
                obj.selectedRegion = new List<String>{'ACT - Albury'};
                    obj.selectedLocation = new  List<String>{'Sydney'};
                        obj.selectedInterest = new List<string> {'Sports'};
                            obj.filterQuery();
        
        System.debug('obj.familyAttendance: ' + obj.familyAttendance);
        obj.familyAttendance[0].attendance.FA_00000__c = 'Invited';
        obj.process();
        obj.selectedAttendanceValue = 'Accepted';
        obj.process();
        obj.selectedAttendanceValue = 'Request To Attend';
        obj.process();
        
        
        pageReference pageRef = obj.saveClose();
        
        Test.stopTest();
        
    }
    
    static testMethod void testFamilyInviationAgedCamp() {
        
        
        Map<String, RecordType> rMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType])
            rMap.put(r.DeveloperName, r);
        
        
        Account a = New Account( Name = 'Family', RecordTypeId = rMap.get('Family').Id );
        insert a;
        
        Contact fm1 = new Contact( FirstName = 'Dad', LastName = 'Family', Family_Member_Type__c = 'Father', AccountId = a.Id, RecordTypeId = rMap.get('Family_Member').Id );
        insert fm1;
        
        Contact fm2 = new Contact( FirstName = 'Sibling', LastName = 'Family', Family_Member_Type__c = 'Brother', AccountId = a.Id, RecordTypeId = rMap.get('Family_Member').Id );
        insert fm2;
        
        Contact fm3 = new Contact( FirstName = 'Patient', LastName = 'Family', Exclude_from_portal__C = False, Family_Member_Type__c = 'Patient', AccountId = a.Id, BirthDate = System.Today().addYears(-8), RecordTypeId = rMap.get('Family_Member').Id );
        insert fm3;
        
        Campaign cam = new Campaign( Name = 'Campaign Name', isActive = true, RecordTypeId = rMap.get('Age_Camp').Id );
        Insert cam;
        
        Registration_Type__c rt = new Registration_Type__c( Name = 'Jnr Camp', Event__c = cam.Id, Ticket_Type__c = 'Jnr Camp', RecordTypeId = rMap.get('Aged_Camp').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        insert rt;
        
        
        Test.startTest();
        
        Test.setCurrentPage(Page.FamilyInvitations);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);
        
        FamilyInvitationsController obj = new FamilyInvitationsController(sc);
        
        obj.getRegistrationTypes();
        
        //Family Picklist
        obj.getAttendanceValues();
        obj.getFamilyTypes();
        obj.getRegions();
        obj.getInterests();
        obj.getLocations();
        
        obj.selectedAttendance = new List<String>{'--None--'};
            obj.filterQuery();
        
        obj.familyAttendance[0].attendance.FA_00000__c = 'Invited';
        obj.process();
        obj.clearFilter();
        pageReference pageRef = obj.saveClose();
        
        Test.stopTest();
        
    }
    
    
    static testMethod void testFamilyInviationVolunteer() {
        
        
        Map<String, RecordType> rMap = new Map<String, RecordType>();
        Map<String, RecordType> aMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName, SobjectType FROM RecordType])
        {
            rMap.put(r.DeveloperName, r);
            if(r.SobjectType == 'Account'){
                aMap.put(r.DeveloperName, r);
            } 
        }
            
        
        List<RecordType> cRTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND DeveloperName = 'Volunteer'];
        List<RecordType> vsRTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Volunteer_Skill__c' AND DeveloperName = 'Working_With_Children_Check'];
         

        Account a = New Account( Name = 'Family', RecordTypeId = aMap.get('Family').Id );
        insert a;
        
        Contact vol = new Contact( FirstName = 'Dad', AccountId = a.Id, LastName = 'Family', Volunteer_Status__c='Volunteer',Volunteer_Eligibility__c  = 'Currently Eligible', Date_From__c = System.Today().addMonths(-6), RecordTypeId = cRTypes[0].Id );
        insert vol;
        
        
        Volunteer_Skill__c vs = new Volunteer_Skill__c(Volunteer__c = vol.id, RecordTypeId = vsRTypes[0].Id, Skill_Description__c='WWCC/Police Check',Expires__c = System.Today().addMonths(6), license__c='NSW',license_no__c='A');
        insert vs;
        
        Volunteer_Checklist__c vc = new Volunteer_Checklist__c(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='Photo ID Sighted');
        insert vc;
        vc = new Volunteer_Checklist__C(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='Code of Conduct v2018');
        insert vc;
        vc = new Volunteer_Checklist__C(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='SGC&YP B&P');
        insert vc;
        vc = new Volunteer_Checklist__C(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='Volunteer Interview');
        insert vc;
        vc = new Volunteer_Checklist__C(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='Volunteer References');
        insert vc;
        
        Volunteer_Course__c vcourse = new Volunteer_Course__c(Volunteer__c = vol.id, Course_Date__c = System.Today().addMonths(-6),ACF_Verified__c=True, Course__c='Online Induction - ACF SCYP');
        insert vcourse;
        
        
        Campaign cam = new Campaign( Name = 'Campaign Name', isActive = true, RecordTypeId = rMap.get('Family_Camp').Id );
        Insert cam;
        
        Registration_Type__c rt = new Registration_Type__c( Name = 'Ticket', Event__c = cam.Id, RecordTypeId = rMap.get('Volunteer').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        insert rt;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.FamilyInvitations);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);
        
        FamilyInvitationsController obj = new FamilyInvitationsController(sc);
        
        obj.getRegistrationTypes();
        
        //Other Picklist
        obj.getAttendanceValues();
        obj.getFamilyTypes();
        obj.getRegions();
        obj.getInterests();
        obj.getLocations();
        obj.getStatus();
        
        //Volunteer Picklist
        obj.getRegisterValues();
        obj.getBranches();
        obj.getSkills();
        obj.getTypes();
        
        obj.selectedAttendance = new List<String>{'--None--'};
            obj.filterQuery();
        
        if(obj.volunteerAttendance != null && obj.volunteerAttendance.size() > 0){
            obj.volunteerAttendance[0].attendance.Attendance__c = 'Invited';
            obj.process();
        }
        
        
        obj.selectedAttendanceValue = 'Accepted';
        obj.process();
        obj.selectedAttendanceValue = 'Request To Attend';
        obj.process();
        pageReference pageRef = obj.saveClose();
        obj.clearFilter();
        obj.selectedAttendance = new List<String>{'--None--'};
            obj.selectedRegion = new List<String>{'ACT - Albury'};
                obj.selectedLocation = new  List<String>{'Sydney'};
                    obj.selectedBranch = new  List<String>{'Sydney'};
                        
                        obj.selectedType =  new  List<String>{'Rover'};
                            obj.selectedSkills = new List<String>{'First Aid'};
                                
                                obj.filterQuery();
        
        Test.stopTest();
        System.assertEquals(0, obj.volunteerAttendance.size(),'Volunteer attendance after calling filter query should be 0');
        System.assertEquals(null, obj.familyAttendance, 'Family attendance should be null as code would try to instantiate volunteer attendance');
        
    }
    
    static testMethod void testFamilyInviationVolunteerTraining() {
        
        
        Map<String, RecordType> rMap = new Map<String, RecordType>();
        Map<String, RecordType> aMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName, SobjectType FROM RecordType])
        {
            rMap.put(r.DeveloperName, r);
            if(r.SobjectType == 'Account'){
                aMap.put(r.DeveloperName, r);
            } 
        }
        
        List<RecordType> cRTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND DeveloperName = 'Volunteer'];
        List<RecordType> vsRTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Volunteer_Skill__c' AND DeveloperName = 'Working_With_Children_Check'];
        
        Account a = New Account( Name = 'Family', RecordTypeId = aMap.get('Family').Id );
        insert a;
        
        Contact vol = new Contact( AccountId = a.Id, FirstName = 'Dad', LastName = 'Family', Volunteer_Status__c='Volunteer',Volunteer_Eligibility__c  = 'Currently Eligible', Date_From__c = System.Today().addMonths(-6), RecordTypeId = cRTypes[0].Id );
        insert vol;
        
        
        Volunteer_Skill__c vs = new Volunteer_Skill__c(Volunteer__c = vol.id, RecordTypeId = vsRTypes[0].Id, Skill_Description__c='WWCC/Police Check',Expires__c = System.Today().addMonths(6), license__c='NSW',license_no__c='A');
        insert vs;
        
        Volunteer_Checklist__c vc = new Volunteer_Checklist__c(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='Photo ID Sighted');
        insert vc;
        vc = new Volunteer_Checklist__C(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='Code of Conduct v2018');
        insert vc;
        vc = new Volunteer_Checklist__C(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='SGC&YP B&P');
        insert vc;
        vc = new Volunteer_Checklist__C(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='Volunteer Interview');
        insert vc;
        vc = new Volunteer_Checklist__C(Volunteer__c = vol.id,Date_Completed__c=System.Today().addMonths(-6),Volunteer_Check_List__c='Volunteer References');
        insert vc;
        
        Volunteer_Course__c vcourse = new Volunteer_Course__c(Volunteer__c = vol.id, Course_Date__c = System.Today().addMonths(-6),ACF_Verified__c=True, Course__c='Online Induction - ACF SCYP');
        insert vcourse;
        
        
        Campaign cam = new Campaign( Name = 'Campaign Name', isActive = true, RecordTypeId = rMap.get('Family_Camp').Id );
        Insert cam;
        
        Registration_Type__c rt = new Registration_Type__c( Name = 'Ticket', Event__c = cam.Id, RecordTypeId = rMap.get('Volunteer_Training').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        insert rt;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.FamilyInvitations);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);
        
        FamilyInvitationsController obj = new FamilyInvitationsController(sc);
        
        obj.selectedAttendance = new List<String>{'--None--'};
            obj.filterQuery();
        
        obj.getRegistrationTypes();
        
        //Other Picklist
        obj.getAttendanceValues();
        obj.getFamilyTypes();
        obj.getRegions();
        obj.getInterests();
        obj.getLocations();
        obj.getStatus();
        
        //Volunteer Picklist
        obj.getRegisterValues();
        obj.getBranches();
        obj.getSkills();
        obj.getTypes();
        
        
        obj.volunteerAttendance[0].attendance.Attendance__c = 'Invited';
        obj.process();
        obj.selectedAttendanceValue = 'Accepted';
        obj.process();
        obj.selectedAttendanceValue = 'Request To Attend';
        obj.process();
        
        pageReference pageRef = obj.saveClose();
        obj.clearFilter();
        delete(vc);
        
        obj.selectedAttendance = new List<String>{'--None--'};
            obj.selectedRegion = new List<String>{'ACT - Albury'};
                obj.selectedLocation = new  List<String>{'Sydney'};
                    obj.selectedBranch = new  List<String>{'Sydney'};
                        
                        obj.selectedType =  new  List<String>{'Rover'};
                            obj.selectedSkills = new List<String>{'First Aid'};
                                
                                obj.filterQuery();
        
        Test.stopTest();
        
    }
    
    
    static testMethod void testFamilyInviationCorpVolunteer() {
        
        
        Map<String, RecordType> rMap = new Map<String, RecordType>();
        Map<String, RecordType> aMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName, SobjectType FROM RecordType])
        {
            rMap.put(r.DeveloperName, r);
            if(r.SobjectType == 'Account'){
                aMap.put(r.DeveloperName, r);
            } 
        }
        
        List<RecordType> cRTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND DeveloperName = 'Volunteer'];
        List<RecordType> vsRTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Volunteer_Skill__c' AND DeveloperName = 'Working_With_Children_Check'];
        
        Account a = New Account( Name = 'Family', RecordTypeId = aMap.get('Family').Id );
        insert a;
        
        Contact vol = new Contact( FirstName = 'Dad', LastName = 'Family', AccountId=a.Id, Volunteer_Status__c='Volunteer',Volunteer_Eligibility__c  = 'Currently Eligible', Date_From__c = System.Today().addMonths(-6), RecordTypeId = cRTypes[0].Id );
        insert vol;
        
        
        Campaign cam = new Campaign( Name = 'Campaign Name', isActive = true, RecordTypeId = rMap.get('Family_Camp').Id );
        Insert cam;
        
        Registration_Type__c rt = new Registration_Type__c( Name = 'Ticket', Corporate_Partner__c =a.id, Event__c = cam.Id, RecordTypeId = rMap.get('Corporate_Volunteer').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        insert rt;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.FamilyInvitations);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);
        
        FamilyInvitationsController obj = new FamilyInvitationsController(sc);
        
        obj.selectedAttendance = new List<String>{'--None--'};
            obj.selectedRegion = new List<String>{'ACT - Albury'};
                obj.selectedLocation = new  List<String>{'Sydney'};
                    obj.selectedBranch = new  List<String>{'Sydney'};
                        
                        obj.selectedType =  new  List<String>{'Rover'};
                            obj.selectedSkills = new List<String>{'First Aid'};
                                
                                obj.filterQuery();
        
        obj.getRegistrationTypes();
        
        //Other Picklist
        obj.getAttendanceValues();
        obj.getFamilyTypes();
        obj.getRegions();
        obj.getInterests();
        obj.getLocations();
        obj.getStatus();
        
        //Volunteer Picklist
        obj.getRegisterValues();
        obj.getBranches();
        obj.getSkills();
        obj.getTypes();
        
        obj.selectedAttendanceValue = 'Invited';
        obj.process();
        obj.selectedAttendanceValue = 'Accepted';
        obj.process();
        obj.selectedAttendanceValue = 'Request To Attend';
        obj.process();
        
        pageReference pageRef = obj.saveClose();
        obj.clearFilter();
        
        Test.stopTest();
        
    }    
    
   
    
    
}