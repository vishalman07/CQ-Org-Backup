global with sharing class portalLoginController {
    public Boolean hasPageMessages {
    	get {
	    	return ApexPages.hasMessages();
    	}
    }
    
    global String username{get;set;}
    global String password{get;set;}
    
    global portalLoginController () {}
    
    global PageReference forwardToCustomAuthPage() {
        return new PageReference( '/portalLogin');
    }
    
    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        System.debug(startUrl);
        return Site.login(username, password, startUrl);
    }
    
    global PageReference forgotPassword() {
    	PageReference p = Page.portalForgotPassword;
    	p.setRedirect(true);
    	
    	return p;
    }
    
    global PageReference register() {
    	PageReference p = Page.portalRegister;
    	p.setRedirect(true);
    	
    	return p;
    }

}