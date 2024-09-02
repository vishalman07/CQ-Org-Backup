trigger ContactPortalAccess on Contact (after insert, after update) {
        if (userinfo.getUserName() != 'cq@noblecx.com.au') {

    Set<Id> updateContactIds = new Set<Id>();

    for (Contact c : Trigger.new) {
        if (c.Portal_Access__c != null && (c.Portal_Access__c == 'Activate' || c.Portal_Access__c == 'Deactivate'))
            updateContactIds.add(c.Id);
        else if (Trigger.isUpdate && Trigger.oldMap.get(c.Id).Portal_Access_Type__c != c.Portal_Access_Type__c)
            updateContactIds.add(c.Id);
    }

    if (!updateContactIds.isEmpty()) {
        List<Contact> updateContacts = new List<Contact>([SELECT Id, Portal_Access__c, Portal_Access_Type__c, Portal_Access_Error__c FROM Contact WHERE Id IN :updateContactIds]);

        if (!updateContacts.isEmpty() && !System.isBatch())
            System.enqueueJob(new ContactPortalToggle(updateContacts));

    }
        }
       }