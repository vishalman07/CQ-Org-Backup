trigger familyPeriodAllocations on Registration_Period_Family_Attendance__c (after insert, after update, after delete) {

    Set<Id> rpIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Registration_Period_Family_Attendance__c fa : Trigger.New) {
            rpIds.add(fa.Registration_Period__c);
        }
    }
    
    if(Trigger.isDelete || Trigger.isUpdate) {
        for(Registration_Period_Family_Attendance__c fa : Trigger.Old) {
            rpIds.add(fa.Registration_Period__c);
        }
    }
    
    
    if(!rpIds.isEmpty())
        campQuality.registrationPeriodAllocations(rpIds);
    
}