trigger RegistrationPeriodFamilyAttendanceLookup on Registration_Period_Family_Attendance__c (after insert, after update, after delete) {

	Set<Id> faIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Registration_Period_Family_Attendance__c rpfa : Trigger.New) {
            faIds.add(rpfa.Family_Attendance__c);
        }
    }
    
    if(Trigger.isDelete || Trigger.isUpdate) {
        for(Registration_Period_Family_Attendance__c rpfa : Trigger.Old) {
            faIds.add(rpfa.Family_Attendance__c);
        }
    }
    
    List<Family_Attendance__c> fas = [SELECT Id, Registration_Period__c, 
                                      (SELECT Id, Registration_Period__c FROM Registration_Period_Family_Attendances__r ORDER BY CreatedDate DESC) 
                                      FROM Family_Attendance__c WHERE Id IN :faIds];
    
    for(Family_Attendance__c fa : fas) {
        if(fa.Registration_Period_Family_Attendances__r != null && !fa.Registration_Period_Family_Attendances__r.isEmpty()) {
            fa.Registration_Period__c = fa.Registration_Period_Family_Attendances__r[0].Registration_Period__c;
        } else {
            fa.Registration_Period__c = null;
        }
    }
    
    try {
        update fas;
    } catch(DmlException ex) {
        System.debug(ex);
    }
    
}