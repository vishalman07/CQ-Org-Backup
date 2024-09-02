trigger CorporateVolunteersRollup on Contact (after insert) {

/*
 * Disabled on 23/4/2024 by Daniel R - No longer used.
 * 
    
if (userinfo.getUserName() != 'cq@noblecx.com.au') {

	Set<Id> aIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Contact c : Trigger.New) {
        	if(String.isNotEmpty(c.AccountId))
            	aIds.add(c.AccountId);
        }
    }
        
    if(Trigger.isDelete || Trigger.isUpdate) {
        for(Contact c : Trigger.Old) {
        	if(String.isNotEmpty(c.AccountId))
            	aIds.add(c.AccountId);
        }
    }
    
    List<Account> accts = [SELECT Id, Number_of_Volunteers__c,
           	(SELECT Id, Portal_Access_Type__c FROM Contacts)
           	FROM Account WHERE Id IN :aIds];
    
    if(!accts.isEmpty()) {
	    for(Account a : accts) {
	        
	        a.Number_of_Volunteers__c = 0;
	        
	        for(Contact c : a.Contacts) {

	        	if(c.Portal_Access_Type__c != null && c.Portal_Access_Type__c.contains('Volunteer Portal'))
	        		a.Number_of_Volunteers__c++;

	        }

	    }
	    
	    try {
	        update accts;
	    } catch(DmlException ex) {
	        System.debug(ex);
	    }
	}
}

*/
    
}