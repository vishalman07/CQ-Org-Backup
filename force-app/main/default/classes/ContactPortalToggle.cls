public class ContactPortalToggle implements Queueable {
	private List<Contact> portalToggleContacts;

	public ContactPortalToggle(List<Contact> contacts) {
		this.portalToggleContacts = contacts;
	}

	public void execute(QueueableContext qc) {
		List<Contact> portalStatusContacts = new List<Contact>();

		for (Contact c : portalToggleContacts) {
			try {
				// 'Active' added to run EnablePortalContact for assigning new PermissionSet for Portal
				if ((c.Portal_Access__c == 'Activate' || c.Portal_Access__c == 'Active') && PortalContactUtility.EnablePortalContact(c.Id)) {
					c.Portal_Access__c = 'Active';
					c.Portal_Access_Error__c = null;
				} else if (c.Portal_Access__c == 'Deactivate' && PortalContactUtility.DisablePortalContact(c.Id)) {
					c.Portal_Access__c = 'Inactive';
					c.Portal_Access_Error__c = null;
				}
			} catch (Exception e) {
				c.Portal_Access__c = 'Error';
				c.Portal_Access_Error__c = e.getMessage() + e.getLineNumber() + e.getStackTraceString();

				if (c.Portal_Access_Error__c.length() > 3000)
					c.Portal_Access_Error__c = c.Portal_Access_Error__c.substring(0, 3000);
			} finally {
				portalStatusContacts.add(c);
			}
		}

		if (!portalStatusContacts.isEmpty() && !Test.isRunningTest())
			System.enqueueJob(new ContactPortalStatus(portalStatusContacts));
	}
}