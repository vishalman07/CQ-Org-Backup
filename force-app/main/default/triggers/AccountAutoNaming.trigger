trigger AccountAutoNaming on Account (after update) {
    if (userinfo.getUserName() != 'cq@noblecx.com.au') {
        
    

	RecordType rt;

	try {
		rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Family' LIMIT 1];
	} catch (Exception e) {
		System.debug('AccountAutoNaming Cannot find Family Account RecordType: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
	}

	if (rt != null) {
		List<Account> updateAccounts = new List<Account>();

		for (Account a : Trigger.new) {
			if (a.RecordTypeId == rt.Id && !String.isBlank(a.npo02__SYSTEM_CUSTOM_NAMING__c)) {
				Account upAcc = new Account(Id=a.Id, npo02__SYSTEM_CUSTOM_NAMING__c=null);

				updateAccounts.add(upAcc);
			}

		}

		if (!updateAccounts.isEmpty()) {
			try {
				System.debug('AccountAutoNaming updating Accounts: ' + updateAccounts);

				update updateAccounts;
			} catch (Exception e) {
				System.debug('AccountAutoNaming Error updating Accounts: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
			}
		}
	}
   }
}