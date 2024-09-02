global class VolunteerEligibilitySchedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		
		Set<Id> cSet = new Set<Id>();

		//for(Volunteer_Skill__c vs : [SELECT Id, Volunteer__c FROM Volunteer_Skill__c WHERE Volunteer__r.Volunteer_Eligibility__c = 'Currently Eligible' AND (Skill_Description__c LIKE '%WWC%' OR Skill_Description__c = 'Blue Card (QLD) Registration No & Exp Date') AND Expires__c <= :Date.today()]) {
		for(Volunteer_Skill__c vs : [SELECT Id, Volunteer__c FROM Volunteer_Skill__c WHERE Volunteer__r.Volunteer_Eligibility__c = 'Currently Eligible' AND  Expires__c <= :Date.today()]) {
			cSet.add(vs.Volunteer__c);
		}

		campQuality.volunteerEligibility(cSet);

	}
}