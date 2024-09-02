public class portalLandingController {

    private List<PermissionSetAssignment> assignments{get;set;}

	public PageReference goToHomePage() {
		String sitePathPrefix = Site.getPathPrefix().removeStart('/');
        if (Test.isRunningTest())
            sitePathPrefix = 'members';
        System.debug(sitePathPrefix);

        List<Site__c> sList = new List<Site__c>([SELECT Id, Name, Default_Page__c, Required_Permission_Set__c, Default_Page__r.Page_Template__c, Default_Page__r.Page_URL_Name__c, Site_URL__c FROM Site__c WHERE Site_URL_Name__c = :sitePathPrefix AND Default_Page__c != null]);

        Set<String> siteRequiredPSAs = new Set<String>();

        for(Site__c s : sList) {
            if(String.isNotEmpty(s.Required_Permission_Set__c)) {
                System.debug(s.Required_Permission_Set__c);
                siteRequiredPSAs.add(s.Required_Permission_Set__c);
            }
        }

        assignments = [SELECT Id, AssigneeId, PermissionSet.Id, PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId() AND PermissionSet.Name IN :SiteRequiredPSAs];

        for(Site__c s : sList) {
            System.debug('Is available:' + isAvailableSite(s));
            if (isAvailableSite(s)) {

                String sitePath = String.isNotEmpty(s.Site_URL__c) ? s.Site_URL__c : s.Id;
                String pagePath = s.Default_Page__c;

                if(String.isNotEmpty(s.Default_Page__c) && String.isNotEmpty(s.Default_Page__r.Page_URL_Name__c)) {
                    pagePath = s.Default_Page__r.Page_URL_Name__c;
                } 

                return new PageReference('/' + sitePathPrefix + '/' + s.Default_Page__r.Page_Template__c + '?s=' + sitePath + '&p=' + pagePath);
            }
        }

        return Page.portalLogin;
	}

    private Boolean isAvailableSite(Site__c site) {

        for(PermissionSetAssignment psa : assignments) {
            if(String.isEmpty(site.Required_Permission_Set__c) || site.Required_Permission_Set__c == psa.PermissionSet.Name)
                return true;
        }

        return false;

    }
}