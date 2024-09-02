trigger FileAttachmentId on ContentDocumentLink (before insert, before update, after insert, after update, after delete) {

	if(Trigger.isBefore) {

		for(ContentDocumentLink ctl : Trigger.New) {
			ctl.Visibility = 'AllUsers';
		}

	}

	if(Trigger.isAfter) {

		Set<Id> attachIds = new Set<Id>();
		Set<Id> docIds = new Set<Id>();

		if(Trigger.isUpdate || Trigger.isInsert) {

			for(ContentDocumentLink a : Trigger.New) {
				attachIds.add(a.LinkedEntityId);
				docIds.add(a.ContentDocumentId);
			}

		} else if(Trigger.isDelete) {

			for(ContentDocumentLink a : Trigger.Old) {
				attachIds.add(a.LinkedEntityId);
				docIds.add(a.ContentDocumentId);
			}

		}

		Map<Id, Attachment__c> attaches = new Map<Id, Attachment__c>([SELECT Id, AttachmentId__c, Content_Type__c FROM Attachment__c WHERE Id IN :attachIds]);
		Map<Id, ContentDocument> cds = new Map<Id, ContentDocument>([SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :docIds]);

		if(Trigger.isUpdate || Trigger.isInsert) {

			for(ContentDocumentLink a : Trigger.New) {
				if(attaches.containsKey(a.LinkedEntityId) && cds.containsKey(a.ContentDocumentId)) {
					attaches.get(a.LinkedEntityId).AttachmentId__c = cds.get(a.ContentDocumentId).LatestPublishedVersionId;
					attaches.get(a.LinkedEntityId).Content_Type__c = 'File';
				}
			}

		} else if(Trigger.isDelete) {

			for(ContentDocumentLink a : Trigger.Old) {
				if(attaches.containsKey(a.LinkedEntityId)) {
					attaches.get(a.LinkedEntityId).AttachmentId__c = '';
					attaches.get(a.LinkedEntityId).Content_Type__c = '';
				}
			}

		}

		try {
			update attaches.values();
		} catch(DmlException e) {
			System.debug(e);
		}

	}

}