trigger SessionParticipantSession on Session_Participant__c (before insert) {

	Set<Id> sIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Session_Participant__c sp : Trigger.New) {
			sIds.add(sp.Session__c);
		}
	}
	    
	if(Trigger.isDelete || Trigger.isUpdate) {
        for(Session_Participant__c sp : Trigger.Old) {
			sIds.add(sp.Session__c);
		}
	}

	if(!sIds.isEmpty())
		campQuality.sessionVolunteers(sIds);

}