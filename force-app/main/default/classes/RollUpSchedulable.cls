global class RollUpSchedulable implements Schedulable  {

    global void execute(SchedulableContext SC) {
        
        Database.executeBatch(new PSPRollUpBatchable(), 500);
        Database.executeBatch(new VolunteerAttendanceRollUpBatchable(), 500);
        Database.executeBatch(new FamilyAttendanceRollUpBatchable(), 500);
        
    }
    
}