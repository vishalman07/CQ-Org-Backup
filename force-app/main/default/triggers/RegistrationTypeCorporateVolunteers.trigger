trigger RegistrationTypeCorporateVolunteers on Registration_Type__c (after insert) {
//trigger RegistrationTypeCorporateVolunteers on Registration_Type__c (after insert, after update) {

    Set<Id> aIds = new set<Id>();
    List<Registration_Type__c> rts = new List<Registration_Type__c>();
    
    String recordTypeId = '';
    for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Registration_Type__c' AND DeveloperName = 'Corporate_Volunteer']) {
        recordTypeId = rt.Id;
    }
    
    if(Trigger.isInsert) {
        for(Registration_Type__c rt : Trigger.New) {
            if(rt.RecordTypeId == recordTypeId && String.isNotBlank(rt.Corporate_Partner__c)) {
                aIds.add(rt.Corporate_Partner__c);
                rts.add(rt);
            }
        }
    }
    
    if(Trigger.isUpdate) {
        Map<Id, Registration_Type__c> oldMap = Trigger.OldMap;
        
        for(Registration_Type__c rt : Trigger.New) {
            if(rt.RecordTypeId == recordTypeId && String.isNotBlank(rt.Corporate_Partner__c) && oldMap.containsKey(rt.Id) && oldMap.get(rt.Id).Corporate_Partner__c != rt.Corporate_Partner__c) {
            	aIds.add(rt.Corporate_Partner__c);
                rts.add(rt);
            }
        }
    }
    
    Map<String, Account> corpPartners = new Map<String, Account>([SELECT Id, (SELECT Id FROM Contacts/* WHERE Volunteer_Eligible__c = 'Eligible'*/) FROM Account WHERE Id IN :aIds]);
    List<Volunteer_Attendance__c> vas = new List<Volunteer_Attendance__c>();
    
    for(Registration_Type__c rt : rts) {
        if(String.isNotBlank(rt.Corporate_Partner__c) && corpPartners.containsKey(rt.Corporate_Partner__c)) {
            Account cp = corpPartners.get(rt.Corporate_Partner__c);
            
            if(cp.Contacts != null && !cp.Contacts.isEmpty()) {
                for(Contact c : cp.Contacts) {
                    vas.add(new Volunteer_Attendance__c(
                    	Attendance__c = 'Invited',
                        Event__c = rt.Event__c,
                        Registration_Type__c = rt.Id,
                        Participation_Role__c = 'Corporate Volunteer',
                        Volunteer__c = c.Id
                    ));
                }
            }
        }
    }
    
    if(!vas.isEmpty()) {
        try {
            insert vas;
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
    
}