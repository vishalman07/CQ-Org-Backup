public without sharing class portalEventsController {
    
    public Date filterFrom {get;set;}
    public Date filterTo {get;set;}
    public String filterAttendance{get;set;}
    /*public String filterState {get;set;}
    public String filterCity {get;set;}
    public String filterTopic {get;set;}*/
    public String portalEventURL{get;set;}
    
    public String contactType{get;set;}
    
    public String raction{
        get {
            return ApexPages.currentPage().getParameters().get('raction');
        }set;
    }
    
    public Boolean filterContact {
        get{
            if(ApexPages.currentPage().getParameters().containsKey('p')) {

                String pId = ApexPages.currentPage().getParameters().get('p');
                List<Page__c> p;

                if(pId instanceOf Id) {
                
                    p = [SELECT Id, Visualforce__c FROM Page__c WHERE Id = :pId];

                } else {

                    p = [SELECT Id, Visualforce__c FROM Page__c WHERE Page_URL_Name__c = :pId];

                }
                
                if(p != null && p.size() > 0)
                    return p[0].Visualforce__c != 'portalBookings';
                
            }
            
            return false;
        }
        set;
    }
    
    public portalEventsController() {
        
        /*if(filterContact) {
            filterAttendance = ' AND FA_00000__c = \'Invited\' ';
        } else {
            filterAttendance = ' AND (FA_00000__c = \'Request to Attend\' OR FA_00000__c = \'Accepted\' OR FA_00000__c = \'Attended\') ';
        }*/
        //Combine bookings.  
        //
        filterAttendance = ' AND (FA_00000__c = \'Invited\' OR FA_00000__c = \'Request to Attend\' OR FA_00000__c = \'Accepted\' OR FA_00000__c = \'Attended\') ';
        loadEvents();
        loadBookings();
        
        PageReference temp = portalCore.pageLink('Event');

        if(temp != null)
            portalEventURL = temp.getUrl().removeStartIgnoreCase('/apex/');
        
    }
    
    /*public List<SelectOption> getStates() {
        
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('', '--Please Select--'));  
        
        String theQuery = 'SELECT Event_State__c FROM Campaign WHERE Event_State__c != null AND (Type = \'Public Event\' OR Type = \'School Event\') AND Status = \'Open\'';
        
        theQuery += ' GROUP BY Event_State__c ORDER BY Event_State__c';
        
        for(AggregateResult ar : Database.query(theQuery))
            result.add(new SelectOption(String.valueOf(ar.get('Event_State__c')), String.valueOf(ar.get('Event_State__c'))));
        
        return result;
        
    }
    
    public List<SelectOption> getCities() {
        
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('', '--Please Select--'));
        
        String theQuery = 'SELECT Event_City__c FROM Campaign WHERE Event_City__c != null AND (Type = \'Public Event\' OR Type = \'School Event\') AND Status = \'Open\'';
        
        theQuery += ' GROUP BY Event_City__c ORDER BY Event_City__c';
        
        for(AggregateResult ar : Database.query(theQuery))
            result.add(new SelectOption(String.valueOf(ar.get('Event_City__c')), String.valueOf(ar.get('Event_City__c'))));
        
        return result;
        
    }*/
    
    public List<SelectOption> getEventTypes() {
        
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('', '--Please Select--'));
        
        for(AggregateResult ar : [SELECT Event_Type__c FROM Campaign WHERE Event_Type__c != NULL GROUP BY Event_Type__c ORDER BY Event_Type__c])
            result.add(new SelectOption(String.valueOf(ar.get('Event_Type__c')), String.valueOf(ar.get('Event_Type__c'))));
        
        return result;
        
    }
    
    List<String> orderList {get;set;}
    public Map<Id, Map<String, Field>> eventList {get;set;}
    
    public class Field {
        public String Label {get;set;}
        public Object Value {get;set;}
        
        public Field(String l, Object v) {
            this.Label = l;
            this.Value = v;
        }
    }
    
    public Integer numberOfEvents { get { return (numberOfEvents == null ? 0 : numberOfEvents); } set;}
    
    public void loadEvents() {
        
        eventList = new Map<Id, Map<String, Field>>();
        Contact member = portalCore.userContact;
        
        Schema.DescribeSObjectResult objDescribe = Campaign.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        String theQuery = 'SELECT ';
        
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        
        Datetime todayDate = Datetime.now();
        Date todayDate2 = Date.today();

        theQuery = theQuery.subString(0, theQuery.length() - 1);
        //UPDATED DJA 17 NOV 2016
        theQuery += ' FROM Campaign WHERE Registrations_Open__c <= :todayDate ';
            
         theQuery += 'AND  ( Status = \'Approved for portal and invites\' OR Status = \'Snapshot Approved\' OR Status = \'Active\' ) ';
        
        
         	
        //if(filterContact) {
            
            //theQuery += ' AND (Registrations_Open__c = null OR Registrations_Open__c <= :todayDate) ';
            //theQuery += ' AND (Registrations_Closed__c = null OR Registrations_Closed__c >= :todayDate) ';
        
        theQuery += ' AND EndDate  >= :todayDate2' ;
            
        //}
        
        /*if(filterFrom == null || filterTo == null || filterFrom <= filterTo) {
            
            if(filterFrom != null) {
                theQuery += ' AND End_Date__c >= :filterFrom ';
            }
            
            if(filterTo != null) {
                theQuery += ' AND Start_Date__c <= :filterTo ';
            }
            
        } else if(filterFrom != null && filterTo != null) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"From" filter must be before "To" filter.'));
            
        }*/
        
        Id mAccountId = member.AccountId;
            
        theQuery += ' AND Id IN (SELECT Event__c FROM Family_Attendance__c WHERE Family__c = :mAccountId' + filterAttendance + ') ';
        
        theQuery += ' ORDER BY CreatedDate';
          //          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'theQuery: ' + theQuery));

        System.Debug('theQuery: ' + theQuery);
        
        try {
            
            List<Campaign> objList = Database.query(theQuery);
            
            numberOfEvents = objList.size();
            
            System.debug('orderList: ' + objList);   
            
            for(Campaign c : objList) {
                
                //orderList.add(c.Id);
                
                eventList.put(c.Id, new Map<String, Field>());
                
                for(Schema.SObjectField s : fieldMap.values()) {
                                
                    eventList.get(c.Id).put((String)s.getDescribe().getName(), new Field((String)s.getDescribe().getLabel(), c.get(s.getDescribe().getName())));
                    
                }
            }  
            
        } catch(Exception e) {
            
        }
        
    }
    
    public String bookedEvents {get;set;}
    public Map<ID, Map<String,Field>> eBMap {get;set;}
    
    public void loadBookings() {
        
        bookedEvents = '';
        eBMap = new Map<ID, Map<String,Field>>();
        
        Contact member = portalCore.userContact;
        
        Schema.DescribeSObjectResult objDescribe = Family_Attendance__c.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        String theQuery = 'SELECT ';
        
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        
        String mAccountId = member.AccountId;
        
        theQuery += ' FROM Family_Attendance__c WHERE Family__c = :mAccountId';
        
        theQuery += filterAttendance;
        
        try {
        
            for(Family_Attendance__c fa : Database.query(theQuery)) {
                bookedEvents += fa.Event__c;
                
                eBMap.put(fa.Event__c, new Map<String, Field>());
                
                for(Schema.SObjectField s : fieldMap.values()) {
                                
                    eBMap.get(fa.Event__c).put((String)s.getDescribe().getName(), new Field((String)s.getDescribe().getLabel(), fa.get(s.getDescribe().getName())));
                    
                }
                
            }
            
            System.debug('EBMap: ' + eBMap);
                    
        } catch(Exception ex) {
            
        }

        
    }
    
}