trigger PSPAddVenue on PuppetShow__c (before insert) {

	PuppetShow.AddVenue(Trigger.New);

}