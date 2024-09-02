global class portalCore {

    public static Contact userContact {get {

        System.Debug('userContact: ' + userContact);

        if(userContact == null) {

            List<User> uList = new List<User>([SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()]);

            if(!uList.isEmpty()) {

                List<Contact> cList = new List<Contact>([SELECT Id, Name, FirstName, LastName, Email, HomePhone, MailingStreet, MailingCity,
                                                         MailingState, MailingPostalCode, MailingCountry, Preferred_Event_Locations__c, RecordType.DeveloperName,
                                                         Swimming_Ability__c, Shirt_Size__c, Emergency_Contact__c, Emergency_Contact_Phone__c,
                                                         Emergency_Contact_Mobile__c, Emergency_Contact_Relationship__c, Account.Name, Birthdate,
                                                         MobilePhone, Media_Permission_Denied__c, Media_Permission_Functions__c, Requests_no_Marketing_Materials__c, Requests_No_Newsletter__c,
                                                         Media_Permission_Interviews__c, Media_Permission_Photos__c, Media_Permission_Photo_Share__c, media_opt_in_share_participants__c, media_opt_in_take_video_photos__c, Media_Opt_in_Public_Sharing__c,
                                                         Media_Permission_Pub__c, AccountId, Account.OwnerId, Account.Phone, Account.BillingStreet, Media_Permission_All_2019__c, Media_permission_Public_2019__c, Media_permission_corporate_2019__c,
                                                         Account.BillingCity, Account.BillingPostalCode, Account.BillingState, Contact.Volunteer_Last_Training_Date__c
                                                         FROM Contact WHERE Id = :uList[0].ContactId]);

                if(!cList.isEmpty()) {

                    userContact =  cList[0];
                } else {
                    //for testing
                    //userContact = [SELECT Id, Current_Deployment__c, Member_Status__c FROM Contact WHERE Id = '003S000000rlCbs'];
                }
            } else {
                //for testing
                //userContact = [SELECT Id, Current_Deployment__c, Member_Status__c FROM Contact WHERE Id = '003S000000rlCbs'];
            }

        }

        return userContact;

    }   set;}

    public static Map<ID, Map<String, Field>> eventsMap(List<ID> eventIds) {

        Map<ID, Map<String, Field>> eventList = new Map<ID, Map<String, Field>>();

        Integer numberOfEvents;

        Schema.DescribeSObjectResult objDescribe = Campaign.sObjectType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

        String theQuery = 'SELECT ';

        for(Schema.SObjectField s : fieldMap.values())
            theQuery += s.getDescribe().getName() + ',';

        theQuery = theQuery.subString(0, theQuery.length() - 1);

        theQuery += ' FROM Campaign WHERE Id IN :eventIds';

        try {

            List<Campaign> objList = Database.query(theQuery);

            numberOfEvents = objList.size();

            System.debug('orderList: ' + objList);

            for(Campaign c : objList) {

                System.debug('obj: ' + c);

                System.debug('fieldmap: ' + fieldMap);

                eventList.put(c.Id, new Map<String, Field>());

                System.debug('fieldmap: ' + fieldMap);

                for(Schema.SObjectField s : fieldMap.values()) {

                    eventList.get(c.Id).put(
                        (String)s.getDescribe().getName(),
                        new Field((String)s.getDescribe().getLabel(), c.get(s.getDescribe().getName()))
                    );
                    System.debug('fieldmap values: ' + s);

                }
            }

        } catch(Exception e) {

        }

        return eventList;

    }

    public class Field {
        public String Label {get;set;}
        public Object Value {get;set;}

        public Field(String l, Object v) {
            this.Label = l;
            this.Value = v;
        }
    }

    public static PageReference pageLink(String pageName) {

        List<Page__c> ps = [SELECT Id, Page_URL_Name__c, Site__c, Site__r.Site_URL__c FROM Page__c WHERE Name = :pageName];

        if(ps != null && ps.size() > 0) {
            PageReference pRef = Page.portalPage;

            if(String.isNotEmpty(ps[0].Page_URL_Name__c)) {
                pRef.getParameters().put('p', ps[0].Page_URL_Name__c);
            } else {
                pRef.getParameters().put('p', ps[0].Id);
            }

            if(String.isNotEmpty(ps[0].Site__c) && String.isNotEmpty(ps[0].Site__r.Site_URL__c)) {
                pRef.getParameters().put('s', ps[0].Site__r.Site_URL__c);
            } else {
                pRef.getParameters().put('s', ps[0].Site__c);
            }

            pRef.setRedirect(true);

            return pRef;
        } else {
            return null;
        }

    }

}