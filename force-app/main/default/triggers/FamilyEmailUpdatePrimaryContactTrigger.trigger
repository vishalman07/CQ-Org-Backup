trigger FamilyEmailUpdatePrimaryContactTrigger on Account (after insert, after update) {
   /*
if (userinfo.getUserName() != 'cq@noblecx.com.au') {
    Set<String> conIds = new Set<String>();
    
    for(Account a : Trigger.New) {
        if(String.isNotBlank(a.npe01__One2OneContact__c))
            conIds.add(a.npe01__One2OneContact__c);
    }
    
    Map<String, Contact> conMap = new Map<String, Contact>([SELECT Id, Email FROM Contact WHERE Id IN :conIds]);
    List<Contact> updateCons = new List<Contact>();
    
    for(Account a : Trigger.New) {
        if(String.isNotBlank(a.Email__c) && String.isNotBlank(a.npe01__One2OneContact__c) && conMap.containsKey(a.npe01__One2OneContact__c)) {
            Contact con = conMap.get(a.npe01__One2OneContact__c);
            if(con.Email != a.Email__c) {
                con.Email = a.Email__c;
                updateCons.add(con);
            }
        }
    }
    
    if(!updateCons.isEmpty()) {
        try {
            update updateCons;
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
} 
*/
}