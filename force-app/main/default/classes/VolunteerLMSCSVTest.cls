@isTest
public class VolunteerLMSCSVTest {

    @isTest
    public static void testVolunteerLMSCSV() {
        
        Map<String, RecordType> rMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account']){
            rMap.put(r.DeveloperName, r);
        }
            
        Account a = New Account(Name = 'Family', RecordTypeId = rMap.get('Family').Id, Family_Type__c = 'Patient',Regionv2__c='ACT - Albury', Preferred_Event_Locations__c='Sydney', Family_Interests__c = 'Sports');
        insert a;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = a.Id);
        insert con;
        
        List<Contact> cons = [SELECT Id, Constituent_ID__c, FirstName, LastName, Email, Branch_Office__c, MailingState, Volunteer_Types_Training__c  FROM Contact WHERE Id = :con.Id];
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(cons);
        VolunteerLMSCSV vlmscsv = new VolunteerLMSCSV(ssc);
        vlmscsv.getLMSExport();
        
        System.assertNotEquals(vlmscsv.csvString, null);
        
    }
    
}