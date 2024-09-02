global class FamilyAttendanceRollUpBatchable implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date startDate = Date.today().addDays(-2);
        
        return Database.getQueryLocator(
            'SELECT Id FROM Account WHERE Programs_Attended__c != NULL AND Programs_Attended__c > 0'
        );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        
        Set<Id> aIdSet = new Set<Id>();
        
        for(Account acc : scope) {
            aIdSet.add(acc.Id);
        }
        
        if(!aIdSet.isEmpty()) {
        	campQuality.attendanceRollup(aIdSet);
        }
        
    }    
    
    global void finish(Database.BatchableContext bc){}
    
}