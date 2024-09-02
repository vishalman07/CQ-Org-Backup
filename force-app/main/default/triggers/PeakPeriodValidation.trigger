trigger PeakPeriodValidation on Peak_Period__c (before insert, before update) {
    RetreatValidation.checkForExistingPeriod(Trigger.new);
}