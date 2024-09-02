@isTest
private class portalEditProfileControllerTest {
     
    @isTest static void familyProfile() {
        User u = [SELECT ID FROM User Where alias = 'test123'];

        List<Special_Needs__c> lstSpecialNeeds = [SELECT ID FROM Special_Needs__c]; 
        System.assertEquals(2, lstSpecialNeeds.size());

        system.runAs(u) {

            portalEditProfileController pepc = new portalEditProfileController(); 

            pepc.editFamily();
            pepc.saveFamily();
            pepc.cancelFamily();

            Contact c = portalCore.userContact;

            pepc.editContactId = c.Id;

            pepc.editContact();

            pepc.addType = 'DietryNeeds';
            pepc.addSpecialNeed();

            pepc.saveContact();
            pepc.editContact();

            for(String key : pepc.currentNeeds.keySet()) {
                pepc.removeNeedId = key;
                pepc.removeSpecialNeed();
            }

            pepc.saveContact();
            pepc.cancelContact();

            pepc.editContact();

        }
        lstSpecialNeeds = [SELECT ID FROM Special_Needs__c]; 
        System.assertEquals(2, lstSpecialNeeds.size()); 

    }
    
    @isTest static void volunteerProfile() { 

        User u = [SELECT ID FROM User Where alias = 'test123']; 
        List<Special_Needs__c> lstSpecialNeeds = [SELECT ID FROM Special_Needs__c]; 
        System.assertEquals(2, lstSpecialNeeds.size());

        system.runAs(u) {

            portalEditVolunteerProfileController pepc = new portalEditVolunteerProfileController();

            pepc.editContact();

            pepc.addType = 'DietryNeeds';
            pepc.addSpecialNeed();

            pepc.wwc.Skill_Description__c = 'Description';

            pepc.saveContact();
            pepc.cancelContact();

            for(String key : pepc.currentNeeds.keySet()) {
                pepc.removeNeedId = key;
                pepc.removeSpecialNeed();
            }
            
            System.assertEquals(null, pepc.profileImage);

            pepc.newVType.Volunteer_Type__c = 'Volunteer Type';

            pepc.addVolunteerType();

            for(String key : pepc.vTypes.keySet()) {
                pepc.removeVTypeId = key;
                pepc.removeVolunteerType();
            } 
        }

        lstSpecialNeeds = [SELECT ID FROM Special_Needs__c]; 
        System.assertEquals(2, lstSpecialNeeds.size());

    }
    
    @testSetup static void SetupTests() {

        User uContext = TestClassUtil.createStdPortalTestUser();  
        Account a = [SELECT ID FROM Account];
        
        Campaign cmp = new Campaign(Name = 'Campaign Name', Status = 'Planned', isActive = true);

        insert cmp;

        Family_Attendance__c fa = new Family_Attendance__c(Family__c = a.Id, Event__c = cmp.Id, FA_00000__c = 'Request to Attend');

        insert fa;

        Family_Member_Attendance__c fma = new Family_Member_Attendance__c(Event__c = cmp.Id, Attendance__c = 'Request to Attend', 
        Family_Attendance__c = fa.Id, Contact__c = uContext.ContactId);

        insert fma;

        Special_Needs__c sn = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = uContext.ContactId, Long_Description__c = 'Allergic - Garlic');

        insert sn;

        Special_Needs__c sn2 = new Special_Needs__c(AttributeType__c = 'SpecialNeeds', Contact__c = uContext.ContactId, Long_Description__c = 'Allergic - Garlic');

        insert sn2;

        Site__c site = new Site__c(Name = 'Family Portal');

        insert site;

        Page__c page = new Page__c(Name = 'My Events', Site__c = site.Id);

        insert page; 
    }

}