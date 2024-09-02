trigger ContactVolunteerCourse on Volunteer_Course__c (after insert, after update, after delete) {

    Set<Id> cIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Volunteer_Course__c vt : Trigger.New) {
            cIds.add(vt.Volunteer__c);
        }
    }
    
    if(Trigger.isDelete || Trigger.isUpdate) {
        for(Volunteer_Course__c vt : Trigger.Old) {
            cIds.add(vt.Volunteer__c);
        }
    }
    
    campQuality.volunteerEligibility(cIds);
    
}