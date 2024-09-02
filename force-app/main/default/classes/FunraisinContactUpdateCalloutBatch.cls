/********************************************************************************************
* @Name         FunraisinContactUpdateCalloutBatch
* @Author       Amit Yadav
* @Date         09/08/2023
* @Description  This batch do callout to zapier when contact record is updated 
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         09/08/2023         Initial Creation                                                      
******************************************************************************************* */
public class FunraisinContactUpdateCalloutBatch implements Database.Batchable<ContactTriggerHandler.FunraisinWrapperClass>,Database.AllowsCallouts, Database.Stateful {
    //public Set<Id> contactIds;
    private List<ContactTriggerHandler.FunraisinWrapperClass> funraisinList = new List<ContactTriggerHandler.FunraisinWrapperClass>();
    // Constructor to initialize the Contact Id
    public FunraisinContactUpdateCalloutBatch(List<ContactTriggerHandler.FunraisinWrapperClass> conFunList) {
        this.funraisinList = conFunList;
    }
    
    // This method defines the start of the batch job
    public Iterable<ContactTriggerHandler.FunraisinWrapperClass> start(Database.BatchableContext BC) {
        // Query to retrieve a single Contact record based on the provided Contact Id
        //return Database.getQueryLocator('SELECT Id, FirstName, Funraisin_Id__c, MobilePhone, HomePhone, Birthdate, MailingCity, MailingStreet, MailingState, MailingCountry, MailingPostalCode,LastName, Email FROM Contact WHERE Id IN :contactIds');
    	return funraisinList;
    }
    
    // This method is responsible for processing each batch of records
    public void execute(Database.BatchableContext BC, List<ContactTriggerHandler.FunraisinWrapperClass> scope) {
        // Process each Contact record in the scope
        for (ContactTriggerHandler.FunraisinWrapperClass contact : scope) {
            Map<String, String> contactData = new Map<String, String>();      
            // Populate the contactData map with the required data
            contactData.put('FirstName', contact.FirstName);
            contactData.put('LastName', contact.LastName);
            if(!String.isBlank(contact.FunraisinId)){
                if(contact.FunraisinId.contains('funraisin:')){
                    contactData.put('MemberId',contact.FunraisinId.subString(contact.FunraisinId.indexOf(':')+1)); 
                }
                else {
                    contactData.put('MemberId', contact.FunraisinId);
                }
            }
            else {
                contactData.put('MemberId', '');
            }
            contactData.put('email', contact.Email);
            contactData.put('oldEmail', contact.oldEmail);
            contactData.put('Mobile Phone', contact.MobilePhone);
            contactData.put('Home Phone', contact.HomePhone);
            contactData.put('Dob', contact.birthdate);
            contactData.put('strret', contact.MailingStreet);
            contactData.put('state', contact.MailingState);
            contactData.put('city', contact.MailingCity);
            contactData.put('Country', contact.MailingCountry);
            contactData.put('pcode', contact.MailingPostalCode);
            contactData.put('title',contact.title);
            contactData.put('workPhone',contact.workPhone);
            
            // Add more fields as needed
            System.debug('My debug : '+contactData.get('MemberId'));
            // Make the HTTP callout to Zapier
           // HttpZapierCallout(contactData);
        }
    }
    
    // This method is called when the batch job is finished
    public void finish(Database.BatchableContext BC) {
        // You can add any final cleanup logic here
    }
    
    // Method to perform the HTTP callout to Zapier
    public static void HttpZapierCallout(Map<String, String> contactData) {
        String endpoint = label.ZapierUpdateEndPoint;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        System.debug(endpoint);
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        
        // Convert the data to JSON format
        String jsonPayload = JSON.serialize(contactData);
        
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonPayload);
        HttpResponse res = h.send(req);
        
        // Check the response status (you can handle this as needed)
        if (res.getStatusCode() == 200) {
            // Request successfully sent to Zapier
            System.debug('Zapier request sent successfully');
        } else {
            // Handle the error response
            System.debug('Error sending request to Zapier: ' + res.getBody());
        }
    }
}