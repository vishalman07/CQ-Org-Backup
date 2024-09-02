trigger AttachmentId on Attachment (after insert, after update, after delete) {

	Set<Id> attachIds = new Set<Id>();

	if(Trigger.isUpdate || Trigger.isInsert) {

		for(Attachment a : Trigger.New) {
			attachIds.add(a.ParentId);
		}

	} else if(Trigger.isDelete) {

		for(Attachment a : Trigger.Old) {
			attachIds.add(a.ParentId);
		}

	}

	Map<Id, Attachment__c> attaches = new Map<Id, Attachment__c>([SELECT Id, AttachmentId__c, Content_Type__c FROM Attachment__c WHERE Id IN :attachIds]);

	if(Trigger.isUpdate || Trigger.isInsert) {

		for(Attachment a : Trigger.New) {
			if(attaches.containsKey(a.ParentId)) {
				attaches.get(a.ParentId).AttachmentId__c = a.Id;
				attaches.get(a.ParentId).Content_Type__c = 'Attachment';
			}
		}

	} else if(Trigger.isDelete) {

		for(Attachment a : Trigger.Old) {
			if(attaches.containsKey(a.ParentId)) {
				attaches.get(a.ParentId).AttachmentId__c = '';
				attaches.get(a.ParentId).Content_Type__c = '';
			}
		}

	}

	try {
		update attaches.values();
	} catch(DmlException e) {
		System.debug(e);
	}

}