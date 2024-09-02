global class PSPRollUpBatchable implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id FROM Account WHERE Puppet_Show__c != NULL'
        );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        Set<Id> pspAIdSet = new Set<Id>();
        
        for(Account acc : scope) {
            pspAIdSet.add(acc.Id);
        }
        
        if(!pspAIdSet.isEmpty()) {
        	campQuality.puppetShowRollup(pspAIdSet);
        }
    }    
    
    global void finish(Database.BatchableContext bc){}
    
}