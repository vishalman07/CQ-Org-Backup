@istest
public class CampQualityMiscControllerTest {


    static testmethod void TestSendEmailSelected() {

        // set up intial test data
        Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'Campaign Name' LIMIT 1];

        Family_Attendance__C fa = [SELECT Id FROM Family_Attendance__C WHERE event__C = :cam.id LIMIT 1];

        Contact contact = [SELECT Id FROM Contact WHERE FirstName ='Kid'].get(0);

        System.debug('camcam' + cam);
        System.debug(fa);
        CampaignMember campaignMember = new CampaignMember(
            CampaignId = cam.Id,
            Family_Attendance__c = fa.Id,
            ContactId = contact.Id,
            Status = 'Invitation Sent'
        );
        insert campaignMember;

        //point to our VF page
        PageReference p = Page.SendSelectedEmail;
        Test.setCurrentPageReference(p);

        ApexPages.currentPage().getParameters().put('campaignId', cam.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);


        SendSelectedEmailController obj = new SendSelectedEmailController(sc);

        obj.markBy = 'Family';
        EmailTemplate et = [SELECT Id from EmailTemplate where developername ='Child_Match_Up_Letter' LIMIT 1];
        obj.templateId = et.Id;



        PageReference p1 = obj.Cancel();
        system.assert(p1 != null);

        obj.markBy = 'Family';
        PageReference p2 = obj.SendMail();
        system.assertEquals(null, p2);
        system.assertEquals(obj.templateId, et.Id);
        obj.markBy = 'Volunteer';
        p2 = obj.SendMail();
        system.assertEquals(null, p2);
        obj.updateEmailList();


        obj.getlistSOFromEmails();

    }

    static testMethod void testFamilyMemberAttendanceListController() {

        Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'Campaign Name' LIMIT 1];
        Family_Attendance__C fa = [SELECT Id FROM Family_Attendance__C WHERE event__C = :cam.id LIMIT 1];


        PageReference pageRef = Page.FamilyMemberAttendanceList;
        pageRef.getParameters().put('aStatus','Accepted');
        pageRef.getParameters().put('faID',fa.Id);


        FamilyMemberAttendanceListController obj  = new FamilyMemberAttendanceListController();
        obj.faId = fa.Id;
        obj.aStatus = 'Accepted';
        system.assertEquals(obj.fmas[0].Attendance__c,'Accepted');
    }

    static testMethod void testPrintSpecialNeedController() {

        Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'Campaign Name' LIMIT 1];
        Family_Attendance__C fa = [SELECT Id FROM Family_Attendance__C WHERE event__C = :cam.id LIMIT 1];
        contact c = [SELECT Id FROM Contact WHERE FirstName = 'Kid' and LastName = 'Family' LIMIT 1];
        Special_Needs__c sn = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = c.Id, Long_Description__c = 'Allergic - Garlic');
        insert sn;

        ApexPages.StandardController sc = new ApexPages.StandardController(cam);


        PrintSpecialNeedController obj  = new PrintSpecialNeedController (sc);

        system.assertEquals(obj.cam.id,cam.id);
    }


    static testMethod void VolunteerChildListController() {

        Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'Campaign Name' LIMIT 1];
        Volunteer_Attendance__C fa = [SELECT Id FROM Volunteer_Attendance__C WHERE event__C = :cam.id LIMIT 1];


        VolunteerChildListController obj  = new VolunteerChildListController();
        obj.vaid = fa.Id;
        system.assertEquals(obj.fmas[0].contact__r.firstname,'Kid');
    }
    static testMethod void SpecialNeedController() {

        contact c = [SELECT Id FROM Contact WHERE FirstName = 'Kid' and LastName = 'Family' LIMIT 1];
        Special_Needs__c sn = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = c.Id, Long_Description__c = 'Allergic - Garlic');
        insert sn;


        SpecialNeedsListController obj  = new SpecialNeedsListController();
        obj.cId = c.Id;
        system.assertEquals(obj.sneeds[0].Long_Description__c,'Allergic - Garlic');
    }

    static TestMethod void MarkAttendanceController (){
        Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'Campaign Name' LIMIT 1];
        Family_Attendance__c fa = [SELECT Id FROM Family_Attendance__c WHERE event__C =: cam.id LIMIT 1];
        Volunteer_Attendance__C va = [SELECT Id FROM Volunteer_Attendance__C WHERE event__C =: cam.id LIMIT 1];
        PageReference pageRef = Page.MarkAttendance;
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);


        MarkAttendanceController obj  = new MarkAttendanceController (sc);
        //obj.getListOfVolunteers();
        obj.getListOfRatings();
        //obj.aStatus = ;
        obj.setAttendeds();

        obj.markVolunteerRating();
        obj.attendanceType = 'Attendance';
        obj.markby = 'Family Member';

        obj.setAttendeds();
        obj.attendId = fa.id;

        obj.markattended();
        obj.markBy = 'Volunteer';
        obj.setAttendeds();
        obj.attendId = va.id;
        obj.markattended();

        obj.markVolunteerRating();


        //obj.matchVolunteer();

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


        Contact vol = new Contact( FirstName = 'Dad', LastName = 'Family', Volunteer_Eligibility__c  = 'Currently Eligible', AccountId = a.Id,  Date_From__c = System.Today().addMonths(-6), RecordTypeId = cMap.get('Volunteer').Id );
        insert vol;
 

        Contact fm1 = new Contact( FirstName = 'Kid', LastName = 'Family', Family_Member_Type__c = 'Father', AccountId = a.Id, RecordTypeId = cMap.get('Family_Member').Id );
        insert fm1;

        //Contact fm2 = new Contact( FirstName = 'Sibling', LastName = 'Family', Family_Member_Type__c = 'Brother', AccountId = a.Id, RecordTypeId = cMap.get('Family_Member').Id );
        //insert (fm2);


        Campaign cam = new Campaign( Name = 'Campaign Name', isActive = true, RecordTypeId = rMap.get('Age_Camp').Id );
        Insert cam;
        //insert c1;



        //Registration_Type__c rt = new Registration_Type__c( Name = 'Jnr Camp', Event__c = cam.Id, Ticket_Type__c = 'Jnr Camp', RecordTypeId = rMapRType.get('Aged_Camp').Id, Number_Available__c = 20, Family_Ticket_Size__c = 2, Initial_Allocation__c = 200);
        //insert rt;
        Family_Attendance__c fa = new Family_Attendance__c(Family__c = a.Id, Event__c = cam.Id, FA_00000__c = 'Accepted');

        insert fa;
        Volunteer_Attendance__c va = new Volunteer_Attendance__c(Event__c = cam.Id, Attendance__c = 'Accepted', Volunteer__c = vol.id);
        insert va;

        Family_Member_Attendance__c fma1 = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Accepted', Family_Attendance__c = fa.Id, Contact__c = fm1.Id, Companion__C = va.id);
        insert fma1;
        //Family_Member_Attendance__c fma2 = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Accepted', Family_Attendance__c = fa.Id, Contact__c = c1[2].Id);
        //insert fma2;
        //      Family_Member_Attendance__c fma3 = new Family_Member_Attendance__c(Event__c = cam.Id, Attendance__c = 'Accepted', Family_Attendance__c = fa.Id, Contact__c = fm3.Id);



    }

}