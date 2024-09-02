public class VolunteerChildListController {

    public String vaId{
        get;
        set {
            vaId = value;
            load();
        }
    }
    
    public List<Family_Member_Attendance__c> fmas{get;set;}
	
    public VolunteerChildListController() {
        
        load();
        
    }
    
    public void load() {
        if(String.isNotEmpty(vaId)) {
            
            fmas = [SELECT Id, contact__r.firstname,contact__r.lastname, Requires_Medication_or_Vitamins__c, contact__r.preferred_first_name__c,contact__r.gender__c, contact__r.Family_Member_Type__c , contact__r.Account.family_type__C, contact__r.Swimming_Ability__c,
 contact__r.age__C,
Family_Attendance__r.Family__r.Name, Family_Attendance__r.Family__r.BillingCity,Family_Attendance__r.Family__r.npe01__One2OneContact__r.preferred_first_name__c, 
Family_Attendance__r.Family__r.npe01__One2OneContact__r.mobilephone ,
Family_Attendance__r.Family__r.npe01__One2OneContact__r.phone  FROM Family_Member_Attendance__c WHERE Companion__C = :vaId];
            
        }
    }
}