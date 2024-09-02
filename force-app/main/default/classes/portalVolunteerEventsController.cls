public with sharing class portalVolunteerEventsController {
    
    public Date filterFrom {get;set;}
    public Date filterTo {get;set;}
    public String filterAttendance{get;set;}

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
                    return p[0].Visualforce__c != 'portalVolunteerBookings';
                
            }
            
            return false;
        }
        set;
    }
    
    public portalVolunteerEventsController() {
        
       // if(filterContact) {
         //   filterAttendance = ' AND Attendance__c = \'Invited\' ';
       // } else {
         //   filterAttendance = ' AND (Attendance__c = \'Request to Attend\' OR Attendance__c = \'Accepted\' OR Attendance__c = \'Attended\') ';
        //}
        //
        //
        filterAttendance = ' AND (Attendance__c = \'Invited\' OR Attendance__c = \'Request to Attend\' OR Attendance__c = \'Accepted\' OR Attendance__c = \'Attended\') '; 
        
        loadEvents();
        loadBookings();
        
        String eventPage = 'Volunteer Event';
        
        if(ApexPages.currentPage().getParameters().get('s') == 'corpVolunteerPortal') {
            eventPage = 'Corporate Volunteer Event';
        }
        
        PageReference temp = portalCore.pageLink(eventPage);
        
        if(temp != null)
            portalEventURL = temp.getUrl().removeStartIgnoreCase('/apex/');
        
    }
    
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
        
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        
        //theQuery += ' FROM Campaign WHERE (Status = \'Planned\' OR Status = \'Pending\' OR Status = \'Active\') ';
        //Updated DJA 17/11/2016 
        theQuery += ' FROM Campaign WHERE (Status = \'Planned\' OR Status = \'Approved for portal and invites\' OR Status = \'Snapshot Approved\' OR Status = \'Active\' ) ';

        Datetime todayDate = Datetime.now();
              Date todayDate2 = Date.today();

        
        if(filterContact) {
            
            theQuery += ' AND (Registrations_Open__c = null OR Registrations_Open__c <= :todayDate) ';
//            theQuery += ' AND (Registrations_Closed__c = null OR Registrations_Closed__c >= :todayDate) ';
            theQuery += ' AND StartDate  >= :todayDate2' ;

        }

        Id memberId = member.Id;
            
        theQuery += ' AND Id IN (SELECT Event__c FROM Volunteer_Attendance__c WHERE Volunteer__c = :memberId' + filterAttendance + ') ';
        
        theQuery += ' ORDER BY CreatedDate';
        
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
        
        Schema.DescribeSObjectResult objDescribe = Volunteer_Attendance__c.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        String theQuery = 'SELECT ';
        
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        
        theQuery = theQuery.subString(0, theQuery.length() - 1);

        Id memberId = member.Id;
        
        theQuery += ' FROM Volunteer_Attendance__c WHERE Volunteer__c = :memberId';
        
        theQuery += filterAttendance;
        
        try {
        
            for(Volunteer_Attendance__c va : Database.query(theQuery)) {
                bookedEvents += va.Event__c;
                
                eBMap.put(va.Event__c, new Map<String, Field>());
                
                for(Schema.SObjectField s : fieldMap.values()) {
                                
                    eBMap.get(va.Event__c).put((String)s.getDescribe().getName(), new Field((String)s.getDescribe().getLabel(), va.get(s.getDescribe().getName())));
                    
                }
                
            }
            
            System.debug('EBMap: ' + eBMap);
                    
        } catch(Exception ex) {
            
        }

        
    }
 

}