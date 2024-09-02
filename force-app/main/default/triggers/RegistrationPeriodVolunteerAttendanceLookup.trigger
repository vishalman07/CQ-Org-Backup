trigger RegistrationPeriodVolunteerAttendanceLookup on Registration_Period_Volunteer_Attendance__c (after insert, after update, after delete) {

	Set<Id> vaIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Registration_Period_Volunteer_Attendance__c rpva : Trigger.New) {
            vaIds.add(rpva.Volunteer_Attendance__c);
        }
    }
    
    if(Trigger.isDelete || Trigger.isUpdate) {
        for(Registration_Period_Volunteer_Attendance__c rpva : Trigger.Old) {
            vaIds.add(rpva.Volunteer_Attendance__c);
        }
    }
    
    List<Volunteer_Attendance__c> vas = [SELECT Id, Registration_Period__c, 
                                         (SELECT Id, Registration_Period__c FROM RegistrationPeriod_Volunteer_Attendances__r ORDER BY CreatedDate DESC) 
                                         FROM Volunteer_Attendance__c WHERE Id IN :vaIds];
    
    for(Volunteer_Attendance__c va : vas) {
        if(va.RegistrationPeriod_Volunteer_Attendances__r != null && !va.RegistrationPeriod_Volunteer_Attendances__r.isEmpty()) {
            va.Registration_Period__c = va.RegistrationPeriod_Volunteer_Attendances__r[0].Registration_Period__c;
        } else {
            va.Registration_Period__c = null;
        }
    }
    
    try {
        update vas;
    } catch(DmlException ex) {
        System.debug(ex);
    }
    
}