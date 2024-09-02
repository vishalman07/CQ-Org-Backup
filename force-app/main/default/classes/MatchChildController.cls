public class MatchChildController {

    public Id camId {get;set;}
    public Map<Id, Family_Member_Attendance__c> fmas{get;set;}
           

     public Map<Id, String> fmaVol{get;set;}

    public String selectedcompainionId {set;get;}
	public String selecteduserId {set;get;}
	private List<Volunteer_Attendance__c> va1; 
    
    public MatchChildController(ApexPages.StandardController sc) {
        
        camId = sc.getId();
        setAttendeds();
        selecteduserId ='';
        selectedcompainionId ='';
        va1 = [SELECT Id, Attendance__c, Volunteer__r.FirstName, Volunteer__r.LastName, Volunteer__r.MailingStreet, Volunteer__r.MailingCity, Volunteer__r.MailingState, Volunteer__r.MailingPostalCode, Volunteer_Rating__c FROM Volunteer_Attendance__c WHERE Event__c = :camId AND (Attendance__c = 'Accepted' OR Attendance__c = 'Attended') order by  Volunteer__r.FirstName, Volunteer__r.LastName];    
    }
	public void matchVolunteer() {
			
            if( fmas != null && fmas.containsKey(attendId)) {
	            Family_Member_Attendance__c fma = fmas.get(attendId);
                if (fmaVol.get(attendId) == ' ') {
                    fma.Companion__c = null;
                    
                }
                else{
                	fma.Companion__c = fmaVol.get(attendId);    
                }
            	
            	attendid = null;
            	
                    //va.Volunteer_Rating__c = vaRating.get(attendId);
                //va.Volunteer_Rating__c = 'Still Settling In';
              System.debug('fma: ' + fma);
            
            try {
                update fma;
                setAttendeds();
            } catch(DmlException ex) {
                System.debug(ex);
                ApexPages.addMessages(ex);
            }
        
            
        	}
        }
    public Id attendId{get;set;}
    
        
    
    public void setAttendeds() {
        selectedcompainionId ='';
		loadFamilies();
        //fmaAttendeds = new Map<Id, Boolean>();
		fmaVol = new Map<Id, String>();
        
        if(fmas != null) {
            for(Id key : fmas.keySet()) {
                if (fmas.get(key).Companion__C != null) {
	                fmaVol.put(key,fmas.get(key).Companion__C);
                    }
                else
                {
                    
                    fmaVol.put(key,' ');
                }
                
                    
            }
        }
        
        
    }
    public List<SelectOption> getListOfVolunteers()
    {
      
               List<SelectOption> VolunteerList = new List<SelectOption>();
       		
               VolunteerList.add(new SelectOption( ' ' ,'---Select---'));
               for(Volunteer_Attendance__c v : va1 )
               {
                          VolunteerList.add(new SelectOption(v.Id , v.Volunteer__r.FirstName + ' ' + v.Volunteer__r.lastname));
               }
              return VolunteerList ;
    }
 
  
    private void loadFamilies() {

        fmas = new Map<Id, Family_Member_Attendance__c>([SELECT Id, Companion__c, Companion_Name__c,Companion__r.Volunteer__r.LastName,  Attendance__c, Contact__r.year_age__C, Contact__r.gender__C, Contact__r.FirstName, Contact__r.LastName, Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode, Contact__R.account.regionv2__c FROM Family_Member_Attendance__c WHERE Family_Attendance__r.Event__c = :camId AND (Attendance__c = 'Accepted' OR Attendance__c = 'Attended')]);

    }
        
}