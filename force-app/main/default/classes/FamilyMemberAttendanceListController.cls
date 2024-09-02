public class FamilyMemberAttendanceListController {
    
    public String aStatus{get;
        set {
            aStatus = value;
            load();
        }
    }
    public String faId{
        get;
        set {
            faId = value;
            load();
        }
    }
    
    public List<Family_Member_Attendance__c> fmas{get;set;}
	
    public FamilyMemberAttendanceListController() {
        
        load();
        
    }
    
    public void load() {
        if(String.isNotEmpty(aStatus) && String.isNotEmpty(faId)) {
            
            fmas = [SELECT Id, Attendance__c, Contact__c, Contact__r.FirstName, Contact__r.PREFERRED_FIRST_NAME__C, Contact__r.LastName,TRANSPORT_PICK_UP_TIME__C,TRANSPORT_PICK_UP_LOCATION__C, TRANSPORT_DROP_OFF_TIME__C, TRANSPORT_DROP_OFF_LOCATION__C,CURRENTLY_ON_TREATMENT__C,REQUIRES_MEDICATION_OR_VITAMINS__C,REQUIRES_DOCTORS_FORM__C,CHILD_IMMUNISATION_SCHEDULE_CURRENT__C,OTC_STANDARD__C, OTC_COMMENTS__C, COMPANION__R.VOLUNTEER__R.PREFERRED_FIRST_NAME__C FROM Family_Member_Attendance__c WHERE Family_Attendance__c = :faId AND Attendance__c = :aStatus];
            
        }
    }
    
}