public class ContactPortalStatus implements Queueable {
	private List<Contact> updateContacts;

	public ContactPortalStatus(List<Contact> contacts) {
		this.updateContacts = contacts;
	}

	public void execute(QueueableContext qc) {
		try {
			update this.updateContacts;
		} catch (Exception e) {
			System.debug('ContactPortalStatus error updating Contacts for Portal Access: ' + e.getMessage());
		}
	}
}