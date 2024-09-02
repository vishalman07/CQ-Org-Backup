public class portalChangePasswdController {
	public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
        
    public portalChangePasswdController() {
    
    }

    public Boolean hasPageMessages {
        get {
            return ApexPages.hasMessages();
        }
    }
}