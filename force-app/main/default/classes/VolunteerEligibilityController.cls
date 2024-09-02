/********************************************************************************************************************************
* @Name         VolunteerEligibilityController
* @Author       Amit Yadav
* @Date         06/05/2024
* @Description  The VolunteerEligibilityController class handles various operations related to volunteer 
eligibility and event management. It provides methods to fetch volunteer status, retrieve 
event details, manage volunteer compliance,interact with external APIs for volunteer data, and handle file uploads.
********************************************************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         06/05/2024        Initial Creation                                                      
********************************************************************************************************************************/

/*The VolunteerEligibilityController class handles various operations related to volunteer 
eligibility and event management. It provides methods to fetch volunteer status, retrieve 
event details, manage volunteer compliance,interact with external APIs for volunteer data, and handle file uploads.*/
public  without sharing class VolunteerEligibilityController {
    
    // Retrieves the volunteer status of a contact associated with a user.
    @AuraEnabled
    public static String getContactDetails(String recUserId){
        // Decrypt the received user ID
        String decryptedString = communityLoginController.decryptedData(recUserId);
        // Query the User object to get the Contact ID associated with the decrypted user ID
        List<User> us = [SELECT Id, ContactId FROM User WHERE Id =:decryptedString];     
        // Query the Contact object to get the contact details using the Contact ID
        LIST<Contact> conList = [SELECT Id, name, Volunteer_Status__c FROM Contact WHERE Id =: us[0].ContactId];     
        return conList[0].Volunteer_Status__c;
    }
    
    @AuraEnabled 
    public static List<EventWrapper> getCamEventDetail(String recUserId){
        
        //Decrypt the User Id 
        String decryptedString = communityLoginController.decryptedData(recUserId);
        List<User> us = [SELECT Id, ContactId FROM User WHERE Id =:decryptedString];
        set<Id> volSet = new set<Id> ();
        // Get the current datetime
        Datetime todayDate = Datetime.now(); 
        // Query to fetch the list of campaigns that meet the specified criteria
        List<Campaign> camList = [SELECT Id,Name, Portal_Title__c,RVSP__c, Event_Start_Date__c, Event_End_Date__c FROM Campaign 
                                  WHERE Id IN(SELECT Event__c FROM Volunteer_Attendance__c WHERE Attendance__c = 'Invited' AND Volunteer__c =: us[0].ContactId) 
                                  AND Registrations_Open__c != null AND Registrations_Open__c <= :todayDate AND EndDate >= Today AND Status =: 'Approved for portal and invites'];
        // Initialize a list to hold the event wrappers
        List<EventWrapper> evetWrapList = new List<EventWrapper>();
        for(Campaign cam : camList){
            // Check if the campaign has both Portal_Title__c and RVSP__c fields not empty
            if (String.isNotBlank(cam.Portal_Title__c) && String.isNotBlank(cam.RVSP__c)) {  
                // Create a new EventWrapper instance set campainvalue
                EventWrapper evetWrap = new EventWrapper();
                evetWrap.eventTitle = cam.Portal_Title__c;                
                // Convert string in the format 'dd-mm-yyyy' by rearranging the elements 
                evetWrap.eventDate = cam.Event_Start_Date__c.day().toString()+'-'+cam.Event_Start_Date__c.month().toString()+'-'+cam.Event_Start_Date__c.year().toString();
                evetWrap.eventId = cam.Id;
                // Add the event wrapper to the list
                evetWrapList.add(evetWrap);
            }    
        }   
        // Return the list of event wrappers
        return evetWrapList;
    }
    
    
    //Volunteer Complaince 
    @AuraEnabled
    public static List<Volunteer_Compliance__c> complainceLearning(String recUserId){
        //decrypt the  userId
        String decryptedString = communityLoginController.decryptedData(recUserId);
        
        List<User> us = [SELECT Id, ContactId FROM User WHERE Id =:decryptedString];
        //Query volunteer complaince based on the contact and keep display order in ascending order and return it
        List<Volunteer_Compliance__c> volComList = [SELECT Id, Volunteer_Criteria__r.Name, Status__c,Date_Expires__c, Volunteer_Criteria__r.Display_Order__c,Litmos_Course_ID__c,Criteria_Type__c,Volunteer_Name__c FROM
                                                    Volunteer_Compliance__c WHERE Volunteer_Name__c =:us[0].ContactId Order by Volunteer_Criteria__r.Display_Order__c ASC];
        return volComList;                
    }
    
    
    //This method is used to perform callout to get user data
    @AuraEnabled
    public Static String litMosCallout(String recUserId){
        String decryptedString = communityLoginController.decryptedData(recUserId);
        List<User> us = [SELECT Id, ContactId, Contact.Email, Contact.Litmos_Account_ID__c  FROM User WHERE Id =:decryptedString];   
        // Extract the email address from the fetched contact details
        String emailAddress = us[0].Contact.Email;
        // Declare variables for the base URL and a map to store Litmus API response
        String baseUrl ;
        Map<String,Object> stringLitmus;
        // Check if Litmos_Account_ID__c field is blank in the contact
        if(String.isBlank(us[0].Contact.Litmos_Account_ID__c)){
            // Construct the base URL for searching user by email
            baseUrl = 'callout:LitmusApiCre/users?source=cqportal&search='+emailAddress+'&format=json';
            // Make a callout to search for the user by email
            String calloutToSearchUser = litMosCalloutmetod(baseUrl);
            // Check if callout response indicates to retry after a delay
            if(calloutToSearchUser.contains('Please try after 1 or 2 minute')){
                return calloutToSearchUser;               
            }   
            // Deserialize the response JSON and extract relevant information
            List<Object> jsonMapList = (List<Object>)JSON.deserializeUntyped(calloutToSearchUser);
            stringLitmus =(Map<String,Object>)  jsonMapList[0];
            if(stringLitmus.containsKey('Id')){
                baseUrl = 'callout:LitmusApiCre/users/'+String.valueof(stringLitmus.get('Id'))+'?source=cqportal&format=json';
            }
        }
        else{
            // Construct the base URL using Litmos_Account_ID__c if available
            baseUrl = 'callout:LitmusApiCre/users/'+us[0].Contact.Litmos_Account_ID__c+'?source=cqportal&format=json';
        }
        //Call the method to get data
        String calloutToGetUser = litMosCalloutmetod(baseUrl);
        if(calloutToGetUser.contains('Please try after 1 or 2 minute')){
            return calloutToGetUser;
        }
        // Deserialize the response JSON and extract relevant information
        stringLitmus  = (Map<String, Object>) JSON.deserializeUntyped(litMosCalloutmetod(baseUrl));
        // Update the contact with the Litmos account ID
        updateCon(us[0].Contact.Id, String.valueof(stringLitmus.get('Id')));
        // Return the LoginKey associated with the Litmos user
        return String.valueof(stringLitmus.get('LoginKey'));
    }
    
    @future
    public static void updateCon(String conId ,string litMosRes){
        // Query to fetch the contact details based on the provided contact ID
        List<Contact> conList = [SELECT Id, Name, Litmos_Account_ID__c, Email from COntact WHERE Id=:conId];
        // Set the Litmos account ID for the fetched contact
        conList[0].Litmos_Account_ID__c = litMosRes;
        // Update the contact record with the new Litmos account ID
        update conList;       
    }
    
    // This method retrieves data from Litmus API for refreshing volunteer compliance records
    @AuraEnabled 
    public static List<Volunteer_Compliance__c> litMosCalloutforRefresh(String recUserId) {
        
        // Decrypt the received user ID
        String decryptedString = communityLoginController.decryptedData(recUserId);
        List<User> us = [SELECT Id, ContactId, Contact.Litmos_Account_ID__c FROM User WHERE Id =:decryptedString];
        String litmosAccId = us[0].Contact.Litmos_Account_ID__c;
        // Construct the base URL for the callout to Litmus API
        String baseUrl = 'callout:LitmusApiCre/users/'+litmosAccId+'/courses?source=cqportal&format=json&start=3';
        // Create an HTTP request object
        HttpRequest req = new HttpRequest();                 
        req.setMethod('GET');
        req.setEndpoint(baseUrl);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        // Create an HTTP object to send the request
        Http http = new Http();
        // Send the HTTP request and capture the response
        HTTPResponse res = http.send(req);
        // Check if the status code of the response indicates a rate limit error
        if (res.getStatusCode() == 429) {
            throw new AuraHandledException('Please try after 1 or 2 minutes');
        }               
        List<RefreshResponse> ref = (List<RefreshResponse>) System.JSON.deserialize(res.getBody(), list<RefreshResponse>.class);
        Map<String,RefreshResponse> refMap = new Map<String,RefreshResponse>();
        // Populate the map with response data using original IDs as keys
        for(RefreshResponse r:ref){
            refMap.put(r.OriginalId, r);
        }
        
        // Query to fetch volunteer compliance records based on the user's contact ID
        List<Volunteer_Compliance__c> volComList = [SELECT Id, Volunteer_Criteria__r.Name, Status__c, Volunteer_Criteria__r.Display_Order__c,Litmos_Course_ID__c,Criteria_Type__c,
                                                    Volunteer_Name__c, PercentageComplete__c FROM Volunteer_Compliance__c WHERE Volunteer_Name__c =:us[0].ContactId Order by Volunteer_Criteria__r.Display_Order__c ASC];
        // Initialize flags to track status updates
        Boolean inProgressUpdated = false;
        Boolean hasInProgress = false;
        Boolean assignedUpdated = false;
        
        if(volComList.size() > 0){
            for(Volunteer_Compliance__c volCom : volComList){
                // Check if the Litmus course ID exists in the response map and if the course is complete
                if(refMap.containskey(volCom.Litmos_Course_ID__c) && refMap.get(volCom.Litmos_Course_ID__c).Complete != false ){       
                    // Update percentage complete for the course
                    volCom.PercentageComplete__c  = refMap.get(volCom.Litmos_Course_ID__c).PercentageComplete;       
                    // Update status based on percentage complete
                    if(refMap.get(volCom.Litmos_Course_ID__c).PercentageComplete  > 0  && refMap.get(volCom.Litmos_Course_ID__c).PercentageComplete < 100){
                        volCom.Status__c  ='In Progress';
                    }
                    // Update status to 'Active' if course is complete
                    Boolean istrueComplete = refMap.get(volCom.Litmos_Course_ID__c).Complete;
                    if(istrueComplete){
                        volCom.Status__c  ='Active';
                        inProgressUpdated = true;
                    }
                    volCom.Litmos_Course_Overdue__C  = refMap.get(volCom.Litmos_Course_ID__c).Overdue;
                    
                    // Ensure volCom.Litmos_Course_ID__c is not null and refMap contains the corresponding value
                    if (volCom.Litmos_Course_ID__c != null && refMap.containsKey(volCom.Litmos_Course_ID__c)) {
                        // Get the DateCompleted value from refMap
                        String dateCompletedValue = refMap.get(volCom.Litmos_Course_ID__c).DateCompleted;
                        
                        // Check if DateCompleted is not null
                        if (dateCompletedValue != null) {
                            // Find the index of '+' in the DateCompleted value
                            Integer plusIndex = dateCompletedValue.indexOf('+');
                            
                            // Check if '+' is found
                            if (plusIndex != -1) {
                                // Extract the substring containing the timestamp
                                String timestampStr = dateCompletedValue.substring(6, plusIndex);
                                
                                // Convert the timestamp string to milliseconds
                                Long timestampMillis = Long.valueOf(timestampStr);
                                
                                // Create DateTime instance from milliseconds
                                DateTime dateTimes = DateTime.newInstance(timestampMillis);
                                
                                // Extract year, month, and day from the DateTime object
                                Integer year = dateTimes.year();
                                Integer month = dateTimes.month();
                                Integer day = dateTimes.day();
                                
                                // Create Date instance from year, month, and day
                                Date dateCompleted = Date.newInstance(year, month, day);
                                
                                // Assign the date to the Date_Completed__c field
                                volCom.Date_Completed__c = dateCompleted;
                            } else {
                                // Handle case where '+' is not found in DateCompleted value
                                System.debug('Error: "+" not found in DateCompleted value.');
                            }
                        } 
                    } 
                }
                // Check if there is already an 'In Progress' record
                if (volCom.Status__c == 'In Progress') {
                    hasInProgress = true;
                }
            }
            // Update 'In Progress' status if necessary
            if (inProgressUpdated && !hasInProgress) {
                for (Volunteer_Compliance__c volCom : volComList) {
                    if (volCom.Status__c == 'Assigned' && !assignedUpdated) {
                        volCom.Status__c = 'In Progress';
                        assignedUpdated = true;
                    }
                }
            }
        }
        // Update and Return the updated volunteer compliance records
        update volComList;		
        return volComList;
    }
    
    //  Makes an HTTP GET callout to the specified URL.
    public static String litMosCalloutmetod(String baseurl){        
        // Create an HTTP request object
        HttpRequest req = new HttpRequest();                 
        req.setMethod('GET');
        req.setEndpoint(baseUrl);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        // Create an HTTP object to send the request
        Http http = new Http();
        // Send the HTTP request and capture the response
        HTTPResponse res = http.send(req);  
        // If the status code is 200 (OK), return the response body
        if(res.getstatusCode() == 200 ){
            return res.getBody();
        }
        // If the status code is 429 (rate limit exceeded), return an error message
        if(res.getstatusCode() == 429){
            return 'Please try after 1 or 2 minute ';
        }
        // Return null if there's an issue with the callout
        return null;
    }
    
    /*
* @method uploadFile() 
* @desc Creates a content version from a given file's base64 and name
* @param {String} base64 - base64 string that represents the file
* @param {String} filename - full file name with extension, i.e. 'products.csv'
* @param {String} recordId - Id of the record you want to attach this file to
* 
* @return {ContentVersion} - returns the created ContentDocumentLink Id if the
*   upload was successful, otherwise returns null
*/    
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId,String recUserId) {
        
        // Decrypt the User ID and retrieve the User record
        String decryptedString = communityLoginController.decryptedData(recUserId);
        List<User> us = [SELECT Id, Name, ContactId FROM User WHERE Id = :decryptedString];
        sendfileUploadImage(filename,recordId,us[0].Id,us[0].Name);
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    
    
    /*
* @method createContentVersion() [private]
* @desc Creates a content version from a given file's base64 and name
* 
* @param {String} base64 - base64 string that represents the file
* @param {String} filename - full file name with extension, i.e. 'products.csv'
* 
* @return {ContentVersion} - returns the newly created ContentVersion, or null
*   if there was an error inserting the record
*/    
    public static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    /*
* @method createContentLink() [private]
* @desc Creates a content link for a given ContentVersion and record
* 
* @param {String} contentVersionId - Id of the ContentVersion of the file
* @param {String} recordId - Id of the record you want to attach this file to
* 
* @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
*   or null if there was an error inserting the record
*/
    public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    public static void sendfileUploadImage(String filename,String recordId, String userId,String name){
        //Here we are invoking the and publishing the platform event.            
        List<Upload_Volunteer_Eligibility_Event__e> inkEvents = new List<Upload_Volunteer_Eligibility_Event__e>();
        Upload_Volunteer_Eligibility_Event__e myEvent = new Upload_Volunteer_Eligibility_Event__e(); 
        
        myEvent.Document_Name__c = filename;
        myEvent.Volunteer_Name__c = name;
        myEvent.getRecordId__c = recordId;
        myEvent.getRecUserId__c = userId;
        
        inkEvents.add(myEvent);
        if(inkEvents.size()>0){
            List<Database.SaveResult> results = EventBus.publish(inkEvents);
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }       
            }
        }
        
        
    }  
    
    // Wrapper class to hold event details for Aura components.
    public Class EventWrapper{
        @AuraEnabled public String eventTitle {get;set;}
        @AuraEnabled public String eventDate {get;set;}
        @AuraEnabled public String eventId {get;set;}
    }
    
    //  Class to represent the response structure for refreshing data.
    public class RefreshResponse {
        public String Id;
        public Boolean Active;
        public Boolean Complete;
        public Double PercentageComplete;
        public String DateCompleted;
        public Boolean Overdue;
        public String OriginalId;
    }
}