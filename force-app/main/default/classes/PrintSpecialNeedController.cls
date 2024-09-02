public with sharing class PrintSpecialNeedController{
public Campaign cam{get;set;}

    public List< Special_Needs__c> VolSn{get; set;}
    public List< Special_Needs__c> FamSn{get; set;}
        public List< Special_Needs__c> VolDiet{get; set;}
    public List< Special_Needs__c> FamDiet{get; set;}

    public PrintSpecialNeedController(ApexPages.StandardController sc){
		if(!Test.isRunningTest())
            sc.addFields(new List<String>{'Name','RecordTypeId','RecordType.DeveloperName'});
            
        cam = (Campaign)sc.getRecord();
   		
        famSn = [SELECT Long_Description__c, Comments__c,Legacy_Comments_To_Be_Purged_June_2017__c, Date__c  ,contact__r.name, contact__r.Age__c, contact__r.family_member_type__C
from Special_Needs__c where  RecordType.DeveloperName='Special_Need'  and  contact__c in (SELECT contact__c from FAMILY_MEMBER_ATTENDANCE__C where (attendance__C='Accepted' or attendance__C='Attended') 
and event__c= :cam.id ) ORDER BY contact__r.lastname, contact__r.firstname];
            
        VolSn = [SELECT Long_Description__c, Comments__c, Legacy_Comments_To_Be_Purged_June_2017__c, Date__c  ,contact__r.name from Special_Needs__c where  RecordType.DeveloperName='Special_Need' 
and contact__C in (SELECT volunteer__c from VOLUNTEER_ATTENDANCE__C where (attendance__C='Accepted' or attendance__C='Attended') and event__c= :cam.id )
ORDER BY contact__r.lastname, contact__r.firstname];
        
        famDiet = [SELECT Long_Description__c, Comments__c,Legacy_Comments_To_Be_Purged_June_2017__c, Date__c  ,contact__r.name, contact__r.Age__c, contact__r.family_member_type__C
from Special_Needs__c where  RecordType.DeveloperName='Dietary_Requirement'  and  contact__c in (SELECT contact__c from FAMILY_MEMBER_ATTENDANCE__C where (attendance__C='Accepted' or attendance__C='Attended') 
and event__c= :cam.id ) ORDER BY contact__r.lastname, contact__r.firstname];       
            
        VolDiet = [SELECT Long_Description__c, Comments__c, Legacy_Comments_To_Be_Purged_June_2017__c, Date__c  ,contact__r.name from Special_Needs__c where  RecordType.DeveloperName='Dietary_Requirement' 
and contact__C in (SELECT volunteer__c from VOLUNTEER_ATTENDANCE__C where (attendance__C='Accepted' or attendance__C='Attended') and event__c= :cam.id )
ORDER BY contact__r.lastname, contact__r.firstname];

}
}