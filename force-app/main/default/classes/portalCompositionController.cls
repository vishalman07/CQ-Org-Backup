public class portalCompositionController {
    public Boolean ItsFalse {
        get {
            return false;
        }
    }
    class PortalSettingException extends Exception { }
    public static final Id FamilyPortalSiteId {get; private set;}
    public static final Id VolunteerPortalSiteId {get; private set;}

    private static Boolean NotAllNulls(List<String> strs) {
        if (strs != null && !strs.isEmpty()) {
            for (String s : strs) {
                if (!String.isBlank(s))
                    return true;
            }
        }

        return false;
    }

    public Map<String, String> ReallyAccessableSites {
        get {
            return AccessableSites;
        }
    }

    // Site__c.Id -> Boolean
    private static Map<Id, Boolean> CanAccessPortalSite;
    // Site__c.Id -> String (PermissionSet.Name) || NULL if no Required PS.
    private static Map<Id, String> SiteRequiredPSA;
    // Site__c.Id -> Contact.<API_Field_Name> that contains Portal 'Role' (Member_Status__c, Training_Status__c)  === Site__c.Contact_Access_Field__c
    private static Map<Id, String> SiteContactAccessField;
    // Sites that you CAN access... Site__c.Name => Link to Default Site Page.. (used for switch-a-roo)
    private static Map<String, String> AccessableSites;

    public static Boolean MultiPortalUser { get { return (AccessableSites.size() > 1); } }

    static {
        Portal_Settings__c portalSettings;
        try {
            portalSettings = Portal_Settings__c.getOrgDefaults();

            FamilyPortalSiteId = Id.valueOf(portalSettings.Family_Portal_Site_Id__c);
            VolunteerPortalSiteId = Id.valueOf(portalSettings.Volunteer_Portal_Site_Id__c);
        } catch (Exception e) {
            System.debug('portalCompositionController Portal_Settings__c NOT SETUP! ' + e.getTypeName() + ' ' + e.getTypeName() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        if ((String.isBlank(FamilyPortalSiteId) || String.isBlank(VolunteerPortalSiteId)) && !Test.isRunningTest())
            throw new PortalSettingException('Portal_Settings__c Custom Setting misconfigured! Set Family_Portal_Site_Id__c and/or Volunteer_Portal_Site_Id__c');

        CanAccessPortalSite = new Map<Id, Boolean>();
        SiteRequiredPSA = new Map<Id, String>();
        SiteContactAccessField = new Map<Id, String>();
        AccessableSites = new Map<String, String>();

        Map<Id, Site__c> pSites = new Map<Id, Site__c>();

        for (Site__c s : [SELECT Id, Name, Required_Permission_Set__c, Contact_Access_Field__c, Default_Page__c, Default_Page__r.Page_Template__c, Default_Page__r.Page_URL_Name__c, Site_URL__c FROM Site__c]) {
            System.debug('Site__c s: ' + s);
            pSites.put(s.Id, s);
            SiteContactAccessField.put(s.Id, s.Contact_Access_Field__c);

            if (!String.isBlank(s.Required_Permission_Set__c)) {
                SiteRequiredPSA.put(s.Id, s.Required_Permission_Set__c);
                CanAccessPortalSite.put(s.Id, false);
            } else {
                SiteRequiredPSA.put(s.Id, null);
                CanAccessPortalSite.put(s.Id, true);
            }

            System.debug('SiteRequiredPSA: ' + SiteRequiredPSA);
            System.debug('CanAccessPortalSite: ' + CanAccessPortalSite);
        }

        if (!SiteRequiredPSA.isEmpty() && NotAllNulls(SiteRequiredPSA.values())) {
            List<PermissionSetAssignment> assignments;

            try {
                assignments = [SELECT Id, AssigneeId, PermissionSet.Id, PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId() AND PermissionSet.Name IN :SiteRequiredPSA.values()];
            } catch (Exception e) {
                System.debug('Yieks! no PSAs for you!  Exception: ' + e.getTypeName() + ' ' + e.getCause() + '  ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
            }


            System.debug('assignments: ' + assignments);
            System.debug('SiteRequiredPSA: ' + SiteRequiredPSA);

            for (Id sId : SiteRequiredPSA.keySet()) {
                if (assignments != null && !assignments.isEmpty()) {
                    String requiredPS = SiteRequiredPSA.get(sId);

                    if (!String.isBlank(requiredPS)) {
                        for (PermissionSetAssignment psa : assignments) {
                            if (psa.PermissionSet.Name == requiredPS) {
                                System.debug('CAN ACCESS SITE VIA PERMISSION SET');

                                CanAccessPortalSite.put(sId, true);
                                AccessableSites.put(pSites.get(sId).Name, pSites.get(sId).Default_Page__r.Page_Template__c + '?s=' + (String.isNotEmpty(pSites.get(sId).Site_URL__c) ? pSites.get(sId).Site_URL__c : sId) + '&p=' + (String.isNotEmpty(pSites.get(sId).Default_Page__c) && String.isNotEmpty(pSites.get(sId).Default_Page__r.Page_URL_Name__c) ? pSites.get(sId).Default_Page__r.Page_URL_Name__c : pSites.get(sId).Default_Page__c));

                                break;
                            }
                        }
                    }
                }

            }

            System.debug('CanAccessPortalSite: ' + CanAccessPortalSite);
            System.debug('AccessableSites: ' + AccessableSites);
        }

    }

    public Boolean error {get { return (error == null ? false : error); }set;}

    public String siteId {get;set;}
    public String pageId {get;set;}

    public String siteUrlName {get;set;}

    public String siteName {get;set;}

    public Contact userContact {
        get {


            if(userContact == null) {

                List<User> uList = new List<User>([SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() AND ContactId != null]);

                if(!uList.isEmpty()) {

                    List<Contact> cList = new List<Contact>([SELECT Id, Portal_Access_Type__c, FirstName, LastName
                                                            FROM Contact WHERE Id = :uList[0].ContactId]);

                    if(!cList.isEmpty()) {

                        userContact =  cList[0];

                    }

                }

            }

            System.debug('UserInfo.getUserId(): ' + UserInfo.getUserId());
            System.Debug('userContact: ' + userContact);


            return userContact;

        }
        set;
    }


    public List<menu> menuList {get;set;}
    public List<menu> courseMenuList {get; set;}

    public class menu {
        public Id Id {get; set;}
        public Boolean RemoveWhenEmpty {get; set;}
        public String Name {get; set;}
        public String MenuTitle {get; set;}
        public Site__c Siter {get; set;}
        public String PageTemplate {get; set;}
        public String AccessRequired {get; set;}

        public Page__c topMenu {get;set;}
        public List<Page__c> menuItems {get;set;}

        public menu(Page__c p) {

            this.topMenu = p;

            menuItems = new List<Page__c>();
            menuItems.addAll(p.Pages__r);

            this.Id = p.Id;
            this.RemoveWhenEmpty = p.Top_Level_Menu_Item_Hidden_When_Empty__c;
            this.Name = p.Name;
            this.MenuTitle = p.Menu_Title__c;
            this.Siter = p.Site__r;
            this.PageTemplate = p.Page_Template__c;
            this.AccessRequired = p.Access_Required__c;

        }
    }


    public Page__c page {get;set;}

    public String pageFilteredContent {
        get {
            if (this.page != null && this.page.Content__c != null && !String.isEmpty(this.page.Content__c)) {
                String filteredContent = this.page.Content__c.replaceAll('font-family\\:[^;]+;?', '');

                return filteredContent;
            }

            return null;
        }
    }

    public portalCompositionController(String sId) {
        this.siteId = sId;

        if(!(siteId instanceOf Id)) {
            siteUrlName = siteId;
            List<Site__c> sites = [SELECT Id, Site_URL__c FROM Site__c WHERE Site_URL__c = :siteId];

            if(!sites.isEmpty())
                siteId = sites[0].Id;
        }
    }

    public portalCompositionController() {

        try {

            siteId = ApexPages.currentPage().getParameters().get('s');
            pageId = ApexPages.currentPage().getParameters().get('p');

            if(!(siteId instanceOf Id)) {
                siteUrlName = siteId;
                List<Site__c> sites = [SELECT Id, Site_URL__c FROM Site__c WHERE Site_URL__c = :siteId];

                if(!sites.isEmpty())
                    siteId = sites[0].Id;
            }

            if(!(pageId instanceOf Id)) {
                List<Page__c> pages = [SELECT Id, Page_URL_Name__c FROM Page__c WHERE Page_URL_Name__c = :pageId];

                if(!pages.isEmpty())
                    pageId = pages[0].Id;
            }

		} catch (Exception e) {
            System.debug('Suspected url param fudges: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
        }

        if (String.isBlank(this.siteId)) {
            for (Id sId : CanAccessPortalSite.keySet()) {
                if (CanAccessPortalSite.get(sId)) {
                    this.siteId = sId;
                    break;
                }
            }
        }

        List<Page__c> pages = [SELECT Id, Page_URL_Name__c, Site__c FROM Page__c WHERE Id = :pageId];

        System.debug('pages: ' + pages);
        System.debug('CanAccessPortalSite: ' + CanAccessPortalSite);

        if(String.isBlank(siteId) || (!pages.isEmpty() && !CanAccessPortalSite.get(pages[0].Site__c))) {
            error = true;
        } else {
            this.buildMenu();
        }
    }

    private void buildMenu() {
            //Menu
            List<Page__c> queryMenuList = new List<Page__c>([SELECT Id, Name, Menu_Title__c, Site__r.Name, Site__r.Default_Page__c, Page_Template__c, Top_Level_Menu_Item_Hidden_When_Empty__c, Access_Required__c, Page_URL_Name__c/*, Requires_Training_Course__c, Requires_Trainee_Payment_In_Full__c*/, (SELECT Id, Name, Menu_Title__c, Page_Template__c, Access_Required__c, Page_URL_Name__c/*, Requires_Training_Course__c, Requires_Trainee_Payment_In_Full__c*/ FROM Pages__r WHERE Disable_Page__c = false ORDER BY Menu_Order__c) FROM Page__c WHERE Site__c = :siteId AND Top_Level_Menu__c = true AND Disable_Page__c = false ORDER BY Menu_Order__c]);

        	//TODO: Investigate this, below debug is causing tests to fail. Out of bounds exception on [0]
        	//DR - 17 Feb 2023: Temporary change to pass tests.
            //System.debug('queryMenuList: ' + queryMenuList);
            //System.debug('queryMenuListSubPages: ' + queryMenuList[0].Pages__r);


            if(queryMenuList.isEmpty()) {
                error = true;
            } else {

                menuList = new List<menu>();
                courseMenuList = new List<menu>();

                for(Page__c mp : queryMenuList) {
                    /*if (mp.Requires_Training_Course__c)
                        courseMenuList.add(new menu(mp));
                    else*/
                       menuList.add(new menu(mp));
                }

                //if(userContact != null) { //added for testing
                    //Remove Top Level
                    // Re-wrote menuList to work with permission based sub-menus.
                    // Can't remove a record for a sub-query so using a custom
                    // run-time object to replicate existing structure.
                    try {

                        Integer j = 0;

                        while (j < courseMenuList.size()) {

                            if (this.menuList.get(j).menuItems.isEmpty() && this.menuList.get(j).RemoveWhenEmpty)
                                this.menuList.remove(j);
                            else
                                j++;

                        }

                    } catch(Exception e) {
                        //System.debug('e: ' + e);
                        System.debug('MenuList access exception: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
                    }
                //}

                System.Debug('Menu after access: ' + menuList);
                System.debug('Course Menu List: ' + courseMenuList);

                if(pageId == null || pageId == '') {
                    System.debug('About to deref index out of bounds....');

                    if (menuList.get(0).topMenu.Site__r == null)
                        pageId = 'a1V5B000000CaR7'; //trying to prevent errors
                    else
                        pageId = menuList[0].topMenu.Site__r.Default_Page__c;
                }

                //siteName
                siteName = menuList[0].topMenu.Site__r.Name;

                System.debug('pageId: ' + pageId);
                System.debug('this.pageId: ' + this.pageId);
                System.debug('this.siteId: ' + this.siteId);

                //Page
                List<Page__c> pageList = new List<Page__c>([SELECT Id, Name, Menu_Title__c, /*Form__c,*/ Title__c, Content__c, Visualforce__c, HTML_Content__c, Page_Template__c, Parent_Page__c, Access_Required__c, /*Requires_Training_Course__c, Requires_Trainee_Payment_In_Full__c,*/ Site__c, Parent_Page__r.Menu_Title__c, Parent_Page__r.Page_Template__c, Site__r.Default_Page__c, Site__r.Default_Page__r.Menu_Title__c, Site__r.Default_Page__r.Page_Template__c, (SELECT Id, Name, Description FROM Attachments WHERE isPrivate = false) FROM Page__c WHERE Id = :pageId AND Disable_Page__c = false]);

                System.debug('pageList: ' + pageList);

                if(pageList.isEmpty()) {
                    error = true;
                } else {

                    page = pageList[0];

                    System.debug('page: ' + page);

                    if(page != null && page.Visualforce__c == null)
                    	page.Visualforce__c = 'portalBlank';
                    else if (page == null) {
                        page = new Page__c(Visualforce__c='portalBlank', Name='RAM Page', Menu_Title__c='RAM Page', Title__c='RAM Page');

                        //?menuList = new List<Page__c>{page};
                        menuList = new List<menu>();
                    }

                }

            }

    }

    public PageReference forwardToCustomAuthPage() {

        if(UserInfo.getUserType() == 'Guest'){
            String startUrl = ApexPages.currentPage().getURL();
            return new PageReference(Site.getPathPrefix() + '/portalLogin?startURL=' +
                                     EncodingUtil.urlEncode(startURL, 'UTF-8'));
        } else {
            return null;
        }

    }

    public static list<SelectOption> getPicklistValues(String ObjectName, String fld) {

        list<SelectOption> options = new list<SelectOption>();

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult objDescribe = SObjectTypeObj.getDescribe();

        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

        list<Schema.PicklistEntry> values;

        try {
            values = fieldMap.get(fld).getDescribe().getPickListValues();
        } catch(Exception e) {
            fld = fld.replace('CICD__', '');
            values = fieldMap.get(fld).getDescribe().getPickListValues();
        }

        System.debug('values: ' + values);

        for (Schema.PicklistEntry a : values)
            options.add(new SelectOption(a.getLabel(), a.getValue()));

        return options;

    }



}