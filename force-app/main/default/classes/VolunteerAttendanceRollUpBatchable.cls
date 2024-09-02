global class VolunteerAttendanceRollUpBatchable implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date startDate = Date.today().addDays(-2);
        
        return Database.getQueryLocator(
            'SELECT Id FROM Contact WHERE RecordType.DeveloperName = \'Volunteer\' AND Volunteer_Attendance__c != NULL'
        );
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope){
        
        Set<Id> cSet = new Set<Id>();
            
        for(Contact v : scope) {
            cSet.add(v.Id);
        }
        
        if(!cSet.isEmpty()) {
        	campQuality.volunteerAttendanceRollup(cSet);
        }
        
    }    
    
    global void finish(Database.BatchableContext bc){}
    
}