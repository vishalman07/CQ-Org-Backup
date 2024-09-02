trigger FamilyMemberAttendanceEvent on Family_Member_Attendance__c (before insert, before update, after update) {

    if(Trigger.isBefore) {
        
        Set<Id> faIds = new Set<Id>();
        
        for(Family_Member_Attendance__c fma : Trigger.New) {
            
            if(String.isNotEmpty(fma.Family_Attendance__c))
                faIds.add(fma.Family_Attendance__c);
            
        }
        
        Map<Id, Family_Attendance__c> faMap = new Map<Id, Family_Attendance__c>([SELECT Id, Event__c FROM Family_Attendance__c WHERE Id = :faIds]);
        
        for(Family_Member_Attendance__c fma : Trigger.New) {
            
            if(String.isNotEmpty(fma.Family_Attendance__c) && faMap.containsKey(fma.Family_Attendance__c) && String.isNotEmpty(faMap.get(fma.Family_Attendance__c).Event__c)) {
                fma.Event__c = faMap.get(fma.Family_Attendance__c).Event__c;
            } else {
                fma.Event__c = null;
            }
        }
        
    }
    
    if(!campQuality.inTriggerContext) {
       
        if(Trigger.isAfter) {
            
            campQuality.inTriggerContext = true;
            
            Set<Id> faSet = new Set<Id>();
            
            for(Family_Member_Attendance__c fma : Trigger.New) {
                if(fma.Attendance__c != Trigger.oldMap.get(fma.Id).Attendance__c)
                    faSet.add(fma.Family_Attendance__c);
            }
            
            if(!faSet.isEmpty()) {
                campQuality.familyAttendanceUpdate(faSet);
            }
            
        }
        
    }
    
}