trigger ContactUpdateUserEmail on Contact (after insert, after update) {
if (userinfo.getUserName() != 'cq@noblecx.com.au') {
    if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && !System.isBatch()) {
        System.enqueueJob(new ContactUpdateUserEmailQueueable(Trigger.NewMap));
    }
}
}