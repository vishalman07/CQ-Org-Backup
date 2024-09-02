public class portalCorporateVolunteerEOIController {

    public Case c{get;set;}
    public Boolean hasError { get { return ApexPages.hasMessages(); } }
    public String successMsg{get;set;}
    public String reason{get;set;}
    public String rTypeName{get;set;}
    
    public portalCorporateVolunteerEOIController() {
        
        loadPage();
        
    }
    
    public void loadPage() {
        
        if(c == null) {
            c = new Case();
        }
        
        List<RecordType> rTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Corporate_Volunteering_EOI'];
        
        if(!rTypes.isEmpty()) {
            c.RecordTypeId = rTypes[0].Id;
        }
        
        if(String.isNotEmpty(reason)) {
            c.Reason = reason;
        }
        
        Contact member = portalCore.userContact;
        
        c.AccountId = member.AccountId;
        c.ContactId = member.Id;
        
        c.Status = 'New';
        c.Origin = 'Community';
        c.Type = 'Question';
        
    }
    
    public void save() {

        if(!Test.isRunningTest()) {
            for(AssignmentRule ar : [select id from AssignmentRule where SobjectType = 'Case' and Active = true]) {
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= ar.id;
                c.setOptions(dmlOpts);
            }
        }

        try{
           insert c; 
        } catch(DmlException ex) {
            System.debug(ex);
            ApexPages.addMessages(ex);
            return;
        }
        
        successMsg = 'Your message has been received. Someone will contact you shortly.';
        c = new Case();
        loadPage();
        
    }
    
}