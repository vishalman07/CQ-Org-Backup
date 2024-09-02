public class portalForgotPasswordController {
    
    public String username {get; set;}   
       
    public portalForgotPasswordController() {}
        
	public PageReference forgotPassword() {
	        Boolean exists = false;

	        try {
	        	User u = [SELECT Id, Username FROM User WHERE IsActive = TRUE AND Username =:username];
	        	exists = true;
	        } catch (Exception e) { }


	        if (!exists) {
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No active user exists with Username \'' + username + '\''));
	        	return null;
	        } else {

		        boolean success = Site.forgotPassword(username);
		        PageReference pr = Page.portalForgotPasswordConfirm;
		        pr.setRedirect(true);
		        
		        if (success) {                          
		                return pr;
		        }
		        return null;
		     }
	}
	
	public Boolean hasPageMessages {
		get {
			return ApexPages.hasMessages();
		}
	}
	
	public PageReference loginPage() {
    	return new PageReference( '/portalLogin');
    }

}