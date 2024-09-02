global class VolunteerEligibilityScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        // Create an instance of the batch class
        VolunteerEligibilityBatch batch = new VolunteerEligibilityBatch();
        
        // Execute the batch with a batch size of 200
        Database.executeBatch(batch, 200);
    }
}