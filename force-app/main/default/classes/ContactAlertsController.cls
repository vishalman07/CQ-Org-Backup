public class ContactAlertsController {

    public String cId{
        get {
            List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :System.UserInfo.getUserId()];
            
            if(users != null && users.size() > 0) {
                return users[0].ContactId;
            }
            
            return null;
        }
        set;
    }
    public List<Task> alerts{get;set;}
    
    public ContactAlertsController() {
        
        loadPage();
        
    }
    
    public void loadPage() {
        
        if(String.isNotEmpty(cId))
	        alerts = [SELECT Id, Subject, Status, Description, WhatId, What.Name, ActivityDate FROM Task WHERE WhoId = :cId /*AND Subject = 'Alert'*/ ORDER BY ActivityDate DESC LIMIT 20];
        
        System.debug('cId: ' + cId);
        System.debug('alerts: ' + alerts);
    }
    
}