trigger PSPRollUpSummary on PSP_Show_Attendee__c (after insert, after update, after delete) {

	Set<Id> cSet = new Set<Id>();

	if(Trigger.isInsert || Trigger.isUpdate) {
		for(PSP_Show_Attendee__c psa : Trigger.New) {
			cSet.add(psa.Contact__c);
		}
	}

	if(Trigger.isDelete || Trigger.isUpdate) {
		for(PSP_Show_Attendee__c psa : Trigger.Old) {
			cSet.add(psa.Contact__c);
		}
	}

	Set<Id> aSet = new Set<Id>();

	if(cSet != null && !cSet.isEmpty()) {
		for(Contact c : [SELECT Id, AccountId FROM Contact WHERE Id IN :cSet AND AccountId != NULL]) {
			aSet.add(c.AccountId);
		}
	}

	campQuality.puppetShowRollup(aSet);

}