public class ContactUpdateUserEmailQueueable implements Queueable {
    
    public Map<Id, Contact> cMap{get;set;}
    
    public ContactUpdateUserEmailQueueable(Map<Id, Contact> conMap) {
        cMap = conMap;
    }
    
    public void execute(QueueableContext qc) {
        
        List<User> us = [SELECT Id, ContactId, Contact.Email, Username, Email FROM User WHERE ContactId = :cMap.keySet()];
        
        for(User u : us) {
            
            if(String.isNotBlank(u.ContactId) && String.isNotBlank(u.Contact.Email)) {
                u.Username = u.Contact.Email;
                u.Email = u.Contact.Email;
            }
            
        }
        
        try {
            update us;
        } catch(DmlException ex) {
            System.debug(ex);
        }
        
    }
    
    
}