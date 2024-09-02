public class MarkAttendanceController {
    
    public Id camId {get;set;}
    public Map<Id, Family_Attendance__c> fas{get;set;}
    public Map<Id, Volunteer_Attendance__c> vas{get;set;}
    public Map<Id, Family_Member_Attendance__c> fmas{get;set;}
  //  public Map<Id, Transport_Participant__c> tps{get;set;}
	    
    public Map<Id, Boolean> faAttendeds{get;set;}
    public Map<Id, Boolean> fmaAttendeds{get;set;}
    //public Map<Id, Boolean> tpAttendeds{get;set;}
    public Map<Id, Boolean> vaAttendeds{get;set;}
    public Map<Id, String> vaRating{get;set;}

    public String attendanceType{get;set;}
    
    public String markBy{get;set;}
    
    public MarkAttendanceController(ApexPages.StandardController sc) {
        
        camId = sc.getId();
        
        setAttendeds();
        markBy = 'Family';
        attendanceType = 'Attendance';
        
    }

    public Id attendId{get;set;}
    
    public List<SelectOption> getListOfRatings() {
		Schema.DescribeFieldResult RatingsFieldDesc = Volunteer_Attendance__c.Volunteer_Rating__c.getDescribe();
        List<SelectOption> RatingsList = new List<SelectOption>();

		for (Schema.Picklistentry picklistEntry : RatingsFieldDesc.getPicklistValues())
		{
			RatingsList.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
		}
        return RatingsList;
    }
    
        public void markVolunteerRating() {
			
            if(attendanceType == 'Attendance' && vas != null && vas.containsKey(attendId)) {

            	Volunteer_Attendance__c va = vas.get(attendId);
            	System.debug('attendanceType: ' + attendanceType);
            
                va.Volunteer_Rating__c = vaRating.get(attendId);
                //va.Volunteer_Rating__c = 'Still Settling In';
                System.debug('va: ' + va);
                
                try {
                    update va;
                } catch(DmlException ex) {
                    System.debug(ex);
                    ApexPages.addMessages(ex);
                }
        
            
        	}
        }
        public void markAttended() {
        
        System.debug('markBy: ' + markBy);
        System.debug('attendId: ' + attendId);
        
        
        if(markBy == 'Family' && fas != null && fas.containsKey(attendId)) {
            
			Family_Attendance__c fa = fas.get(attendId);
            fa.FA_00000__c = faAttendeds.get(attendId) ? 'Attended' : 'Accepted';
            
            try {
                update fa;
            } catch(DmlException ex) {
                System.debug(ex);
                ApexPages.addMessages(ex);
            }
            
        } else if(attendanceType == 'Attendance' && fmas != null && fmas.containsKey(attendId)) {
            
            Family_Member_Attendance__c fma = fmas.get(attendId);
            
            System.debug('attendanceType: ' + attendanceType);
            
            if(attendanceType == 'Attendance') {
                fma.Attendance__c = fmaAttendeds.get(attendId) ? 'Attended' : 'Accepted';
            }
            
            System.debug('fma: ' + fma);
            
            try {
                update fma;
            } catch(DmlException ex) {
                System.debug(ex);
                ApexPages.addMessages(ex);
            }
            
        } else if(attendanceType == 'Attendance' && vas != null && vas.containsKey(attendId)) {

            Volunteer_Attendance__c va = vas.get(attendId);
            
            System.debug('attendanceType: ' + attendanceType);
            
            if(attendanceType == 'Attendance') {
                va.Attendance__c = vaAttendeds.get(attendId) ? 'Attended' : 'Accepted';
            }
            
            System.debug('va: ' + va);
            
            try {
                update va;
            } catch(DmlException ex) {
                System.debug(ex);
                ApexPages.addMessages(ex);
            }

        } 
            /*else if(tps != null && tps.containsKey(attendId)) {
            
            Transport_Participant__c tp = tps.get(attendId);
            
            System.debug('attendanceType: ' + attendanceType);
            
            if(attendanceType == 'Transport Pick Up') {
                tp.Picked_Up__c = tpAttendeds.get(attendId);
            } else if(attendanceType == 'Transport Drop Off') {
                tp.Dropped_Off__c = tpAttendeds.get(attendId);
            }
            
            try {
                update tp;
            } catch(DmlException ex) {
                System.debug(ex);
                ApexPages.addMessages(ex);
            }
            
        }*/
        
    }
    
    public void setAttendeds() {
        
		loadFamilies();
        faAttendeds = new Map<Id, Boolean>();
        fmaAttendeds = new Map<Id, Boolean>();
        //tpAttendeds = new Map<Id, Boolean>();
        vaAttendeds = new Map<Id, Boolean>();
        vaRating = new Map<Id, String>();
        
        if(fas != null) {
            for(Id key : fas.keySet()) {
                faAttendeds.put(key, fas.get(key).FA_00000__c == 'Attended');
            }
        }
        
        if(fmas != null) {
            for(Id key : fmas.keySet()) {
                fmaAttendeds.put(key, fmas.get(key).Attendance__c == 'Attended');            
            }
        }
        
        /*if(tps != null) {
            for(Id key : tps.keySet()) {
                if(attendanceType == 'Transport Pick Up') {
                    tpAttendeds.put(key, tps.get(key).Picked_Up__c);
                } else if(attendanceType == 'Transport Drop Off') {
                    tpAttendeds.put(key, tps.get(key).Dropped_Off__c);
                }
            }
        }*/

        if(vas != null) {
            for(Id key : vas.keySet()) {
                vaAttendeds.put(key, vas.get(key).Attendance__c == 'Attended');
                if (vas.get(key).Volunteer_Rating__c != null) {
                	vaRating.put(key, vas.get(key).Volunteer_Rating__c);    
                }
                else{
                    vaRating.put(key, 'Good Fit');
                }
            }
        }
        
    }
    
    private void loadFamilies() {

        if(markBy == 'Family Member' && attendanceType == 'Attendance') {
            fmas = new Map<Id, Family_Member_Attendance__c>([SELECT Id, Attendance__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode FROM Family_Member_Attendance__c WHERE Family_Attendance__r.Event__c = :camId AND (Attendance__c = 'Accepted' OR Attendance__c = 'Attended')]);
        } 
        //else if(attendanceType == 'Transport Pick Up' || attendanceType == 'Transport Drop Off') {
          //  tps = new Map<Id, Transport_Participant__c>([SELECT Id, Picked_Up__c, Dropped_Off__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode, Participant_Type__c FROM Transport_Participant__c WHERE Transport__r.Event__c = :camId]);
    //    }
    else if(markBy == 'Volunteer' && attendanceType == 'Attendance') {
            vas = new Map<Id, Volunteer_Attendance__c>([SELECT Id, Attendance__c, Volunteer__r.FirstName, Volunteer__r.LastName, Volunteer__r.MailingStreet, Volunteer__r.MailingCity, Volunteer__r.MailingState, Volunteer__r.MailingPostalCode, Volunteer_Rating__c FROM Volunteer_Attendance__c WHERE Event__c = :camId AND (Attendance__c = 'Accepted' OR Attendance__c = 'Attended')]);
        } else {
            fas = new Map<Id, Family_Attendance__c>([SELECT Id, FA_00000__c, Family__r.Name, Family__r.BillingStreet, Family__r.BillingCity, Family__r.BillingState, Family__r.BillingPostalCode, (SELECT Id, Contact__r.FirstName FROM Family_Member_Attendance__r) FROM Family_Attendance__c WHERE Event__c = :camId AND (FA_00000__c = 'Accepted' OR FA_00000__c = 'Attended')]);
        }

    }
        
}