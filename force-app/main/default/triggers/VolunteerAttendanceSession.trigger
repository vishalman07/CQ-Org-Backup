trigger VolunteerAttendanceSession on Volunteer_Attendance__c (after insert, after update, after delete) {

	Set<Id> vaIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        vaIds.addAll(Trigger.NewMap.keySet());
    }
        
    if(Trigger.isDelete || Trigger.isUpdate) {
        vaIds.addAll(Trigger.OldMap.keySet());
    }

	List<Session_Participant__c> sps = [SELECT Id, Session__c FROM Session_Participant__c WHERE Volunteer_Attendance__c IN :vaIds];

	Set<Id> sIds = new Set<Id>();

	for(Session_Participant__c sp : sps) {
		sIds.add(sp.Session__c);
	}

	if(!sIds.isEmpty())
		campQuality.sessionVolunteers(sIds);

}