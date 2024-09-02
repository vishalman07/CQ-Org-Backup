/********************************************************************************************
* @Name         ContactTriggerHandler
* @Author       Amit Yadav
* @Date         09/08/2023
* @Description  This Handler class is use for ContactTrigger On Contact. 
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         09/08/2023         Initial Creation                                                      
******************************************************************************************* */
public class ContactTriggerHandler extends TriggerHandler{
    private Map<Id, Contact> newContactMap;
    private Map<Id, Contact> oldContactMap;
    private List<Contact> newContactList;
    public ContactTriggerHandler() {
        this.newContactMap = (Map<Id, Contact>) Trigger.newMap;
        this.oldContactMap = (Map<Id, Contact>) Trigger.oldMap;
        this.newContactList = (List<Contact>) Trigger.new;
    }
    
    public override void afterUpdate(){
        updateFunraisnMember();        
    }
    /********************************************************************************************
* @Method Name         updateFunraisnMember
* @Author       Amit Yadav
* @Date         09/12/2023
* @Description  This method is used to check the updated contact details and execute the FunraisinContactUpdateCalloutBatch class.
****************************************************************************************** */  
    
    public void updateFunraisnMember(){
        Set<Id> contactIds = new Set<Id>();
        List<FunraisinWrapperClass> funraisinList = new List<FunraisinWrapperClass>();
        for (Contact newContact : newContactList) {
            if(newContact.recordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId()){
                Contact oldContact = oldContactMap.get(newContact.Id);
                
                // Check if the fields you're interested in have changed
                if (newContact.FirstName != oldContact.FirstName ||
                    newContact.LastName != oldContact.LastName ||
                    newContact.Email != oldContact.Email ||
                    newContact.MobilePhone != oldContact.MobilePhone ||
                    newContact.HomePhone != oldContact.HomePhone ||
                    newContact.Birthdate != oldContact.Birthdate ||
                    newContact.MailingStreet != oldContact.MailingStreet ||
                    newContact.MailingState != oldContact.MailingState ||
                    newContact.MailingCity != oldContact.MailingCity ||
                    newContact.MailingCountry != oldContact.MailingCountry ||
                    newContact.MailingPostalCode != oldContact.MailingPostalCode ||
					newContact.Salutation  != oldContact.Salutation ||
                   newContact.npe01__WorkPhone__c  != oldContact.npe01__WorkPhone__c) {
                        
                        // If any of the specified fields have changed, add the Contact Id to the set
                        FunraisinWrapperClass funraisin = new FunraisinWrapperClass();
                        funraisin.lastName 				= newContact.LastName;
                        funraisin.firstName 			= newContact.FirstName;
                        funraisin.email 				= newContact.Email;
                        funraisin.oldEmail 				= oldContact.Email;
                        funraisin.mobilePhone 			= newContact.MobilePhone;
                        funraisin.homePhone 			= newContact.HomePhone;
                        funraisin.birthdate 			= String.ValueOf(newContact.Birthdate);
                        funraisin.mailingStreet 		= newContact.MailingStreet;
                        funraisin.mailingState 			= newContact.MailingState;
                        funraisin.mailingCity 			= newContact.MailingCity;
                        funraisin.mailingCountry 		= newContact.MailingCountry;
                        funraisin.mailingPostalCode 	= newContact.MailingPostalCode;
                        funraisin.FunraisinId 			= newContact.Funraisin_Id__c;
                        funraisin.title     			= newContact.Salutation;
                       	funraisin.workPhone				= newContact.npe01__WorkPhone__c;
                        funraisinList.add(funraisin);  
                    }
            }
            
            if (funraisinList.size() > 0 && !System.isBatch() && !System.isFuture() && !System.isQueueable()) {
                // Enqueue the batch job with the Contact Ids to process
                FunraisinContactUpdateCalloutBatch batchClass = new FunraisinContactUpdateCalloutBatch(funraisinList);
                Database.executeBatch(batchClass, 1);
            }
        }
    }
    public class FunraisinWrapperClass{
        Public String firstName {get; set;}
        public String lastName {get; set;}
        public String title {get; set;}
        public String email {get; set;}
        public String oldEmail {get; set;}
        public String mobilePhone {get; set;}
        public String homePhone {get; set;}
        public String workPhone {get; set;}
        public String birthdate {get; set;}
        public String mailingStreet {get; set;}
        public String mailingState {get; set;}
        public String mailingCity {get; set;}
        public String mailingCountry {get; set;}
        public String mailingPostalCode {get; set;}
        public String FunraisinId {get; set;}
    }
}