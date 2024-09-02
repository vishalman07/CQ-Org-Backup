trigger CorporateVolunteerRegistrationInvite on Contact (after insert) {
    
/*
 * Disabled on 23/4/2024 by Daniel R - No longer used.
 * 
if (userinfo.getUserName() != 'cq@noblecx.com.au') {
    String recordTypeId = '';
    for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Contact' AND DeveloperName = 'Volunteer']) {
        recordTypeId = rt.Id;
    }
    
    Set<Id> aIds = new Set<Id>();
    
    for(Contact c : Trigger.New) {
        if(String.isNotBlank(recordTypeId) && c.RecordTypeId == recordTypeId && String.isNotBlank(c.AccountId)) {
            aIds.add(c.AccountId);
        }
    }
    
    Map<String, Account> accounts = new Map<String, Account>([
        SELECT Id,
        (SELECT Id, Event__c FROM Registration_Types__r WHERE Event__r.Registrations_Closed__c > :Datetime.now())
        FROM Account 
        WHERE Id IN :aIds
    ]);
    
    List<Volunteer_Attendance__c> vas = new List<Volunteer_Attendance__c>();
    
    for(Contact c : Trigger.New) {
        if(String.isNotBlank(recordTypeId) && c.RecordTypeId == recordTypeId && String.isNotBlank(c.AccountId) && accounts.containsKey(c.AccountId)) {
            Account cp = accounts.get(c.AccountId);
            
            if(cp.Registration_Types__r != null && !cp.Registration_Types__r.isEmpty()) {
                for(Registration_Type__c rt : cp.Registration_Types__r) {
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

*/
}