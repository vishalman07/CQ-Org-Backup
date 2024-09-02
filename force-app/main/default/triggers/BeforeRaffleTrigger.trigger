trigger BeforeRaffleTrigger on Raffle_Json_Log__c (after insert) {
	
    if(Trigger.isInsert && Trigger.isAfter){
       // BeforeRaffleTriggerHandler.createRecord(Trigger.new);
    }
}