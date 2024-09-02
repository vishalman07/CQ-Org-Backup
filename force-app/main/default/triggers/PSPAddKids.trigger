trigger PSPAddKids on PuppetShow__c (after insert) {

	PuppetShow.AddKids(Trigger.New);

}