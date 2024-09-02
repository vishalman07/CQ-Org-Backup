public class portalVolunteerHomeController {

    public Account acc{get;set;}
    public Contact con{get;set;}
    
    public portalVolunteerHomeController() {
        
        for(User u : [SELECT Id, ContactId, Contact.Id, Contact.Name, Contact.AccountId, Contact.Account.Id, Contact.Account.Community_Home_Page_Text__c, Contact.Account.Corporate_Contact_Us_Message__c  FROM User WHERE Id = :UserInfo.getUserId()]) {
            
            if(String.isNotBlank(u.ContactId) && String.isNotBlank(u.Contact.AccountId)) {
                con = u.Contact;
                acc = u.Contact.Account;
            }
            
        }
        
    }
    
}