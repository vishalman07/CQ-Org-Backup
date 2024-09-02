trigger TransportParticipantContact on Transport_Participant__c (before insert, before update) {

	Set<Id> faIds = new Set<Id>();
	Set<Id> vaIds = new Set<Id>();

	for(Transport_Participant__c tp : Trigger.New) {

		if(String.isNotEmpty(tp.Family_Member_Attendance__c))
			faIds.add(tp.Family_Member_Attendance__c);

		if(String.isNotEmpty(tp.Volunteer_Attendance__c))
			vaIds.add(tp.Volunteer_Attendance__c);

	}

	Map<Id, Family_Member_Attendance__c> faMap = new Map<Id, Family_Member_Attendance__c>([SELECT Id, Contact__c FROM Family_Member_Attendance__c WHERE Id = :faIds]);
	Map<Id, Volunteer_Attendance__c> vaMap = new Map<Id, Volunteer_Attendance__c>([SELECT Id, Volunteer__c FROM Volunteer_Attendance__c WHERE Id = :vaIds]);

	for(Transport_Participant__c tp : Trigger.New) {

		if(String.isNotEmpty(tp.Family_Member_Attendance__c) && faMap.containsKey(tp.Family_Member_Attendance__c) && String.isNotEmpty(faMap.get(tp.Family_Member_Attendance__c).Contact__c)) {
			tp.Contact__c = faMap.get(tp.Family_Member_Attendance__c).Contact__c;
		} else if(String.isNotEmpty(tp.Volunteer_Attendance__c) && vaMap.containsKey(tp.Volunteer_Attendance__c) && String.isNotEmpty(vaMap.get(tp.Volunteer_Attendance__c).Volunteer__c)) {
			tp.Contact__c = vaMap.get(tp.Volunteer_Attendance__c).Volunteer__c;
		} else {
			tp.Contact__c = null;
		}

	}
}