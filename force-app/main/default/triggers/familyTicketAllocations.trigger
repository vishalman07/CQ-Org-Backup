trigger familyTicketAllocations on Family_Attendance__c (after insert, after update, after delete) {

    Set<Id> rtIds = new Set<Id>();
    Set<Id> faIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Family_Attendance__c fa : Trigger.New) {
            rtIds.add(fa.Registration_Type__c);
        }
        
        faIds.addAll(Trigger.NewMap.keySet());
    }
        
    if(Trigger.isDelete || Trigger.isUpdate) {
        for(Family_Attendance__c fa : Trigger.Old) {
            rtIds.add(fa.Registration_Type__c);
        }
        
        faIds.addAll(Trigger.OldMap.keySet());
    }
    
    if(!rtIds.isEmpty()) {
        campQuality.registrationTypeAllocations(rtIds);
    }
    
    Set<Id> rpIds = new Set<Id>();
    
    for(Registration_Period_Family_Attendance__c rpfa : [SELECT Id, Registration_Period__c FROM Registration_Period_Family_Attendance__c WHERE Family_Attendance__c IN :faIds]) {
        rpIds.add(rpfa.Registration_Period__c);
    }
    
    if(!rpIds.isEmpty()) {
        campQuality.registrationPeriodAllocations(rpIds);
    }

}