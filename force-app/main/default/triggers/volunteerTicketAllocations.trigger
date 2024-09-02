trigger volunteerTicketAllocations on Volunteer_Attendance__c (after insert, after update, after delete) {

    Set<Id> rtIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Volunteer_Attendance__c va : Trigger.New) {
            rtIds.add(va.Registration_Type__c);
        }
    }
        
    if(Trigger.isDelete || Trigger.isUpdate) {
        for(Volunteer_Attendance__c va : Trigger.Old) {
            rtIds.add(va.Registration_Type__c);
        }
    }
    
    
    if(!rtIds.isEmpty())
        campQuality.registrationTypeAllocations(rtIds);

}