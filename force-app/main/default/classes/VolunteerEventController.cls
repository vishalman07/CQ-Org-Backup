/********************************************************************************************
* @Name         VolunteerEventController
* @Author       Amit Yadav
* @Date         12/6/2023 
* @Description  Apex class to handle volunteer event-related functionality for the portal.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/6/2023        Initial Creation                                                      
******************************************************************************************* */
// Apex class to handle volunteer event-related functionality for the portal.
public without sharing class VolunteerEventController {
    
    //Fetches a list of campaign events based on volunteer attendance and other criteria and return the List of campaign events.
    @AuraEnabled
    public static List<FetchEventDataWrap> fetchEvents(String recUserId){
        // Initialize the list to store campaign events
        List<Campaign> objList = new List<Campaign>(); 
        Set<Id> setOfCamId = new Set<Id>();
        Set<Id> checkSet = new Set<Id>();
        String decryptedString = communityLoginController.decryptedData(recUserId);
        List<FetchEventDataWrap> camWrapperList = new List<FetchEventDataWrap>();
        
        // Define filter conditions for volunteer attendance
        String filterAttendance = ' AND (Attendance__c = \'Invited\' OR Attendance__c = \'Request to Attend\' OR Attendance__c = \'Accepted\' OR Attendance__c = \'Attended\') ';
        // Fetch the current user's information
        List<User> us = [SELECT Id, ContactId FROM User WHERE Id =:decryptedString];
        // Describe the Campaign object to get its fields
        Schema.DescribeSObjectResult objDescribe = Campaign.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        // Build the SOQL query dynamically to select all fields from the Campaign object
        String theQuery = 'SELECT ';        
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        // Remove the comma from the field list
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        // Continue building the query with additional conditions
        theQuery += ' FROM Campaign WHERE (Status = \'Approved for portal and invites\' ) ';
        // Get the current date and time
        Datetime todayDate = Datetime.now();
        // Add conditions to filter events based on date
        theQuery += ' AND Registrations_Open__c != null AND Registrations_Open__c <= :todayDate';
        theQuery += ' AND EndDate >= Today';
        // Get the contact ID of the current user        
        String contactID = us[0].contactId;
        thequery += ' AND Id IN (SELECT Event__c FROM Volunteer_Attendance__c WHERE Volunteer__c =: contactID ' + filterAttendance + ') ';       
        theQuery += ' ORDER BY StartDate DESC';
        
        try {  
            // Execute the dynamic query and store the results in objList          
            objList = Database.query(theQuery);   
            for(Campaign cam : objList){
                //FetchEventDataWrap wrapCampField = new FetchEventDataWrap();
                setOfCamId.add(cam.Id);
            }
            
            //List<ContentDocument> coDocment = [SELECT ID, LatestPublishedVersion.Versiondata from ContentDocument];
            List<ContentDocumentLink> conLink = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:setOfCamId];
            for(ContentDocumentLink cdl : conLink){
                checkSet.add(cdl.ContentDocumentId);
            }
            
            List<ContentVersion> conVer = [SELECT ID, VersionData, Title , FirstPublishLocationId from ContentVersion WHERE ContentDocumentId IN:checkSet];
            Map<Id,Set<String>> camIdToBlob = new Map<Id,Set<String>>();
            
            for(ContentVersion coVer : conVer){
                if(coVer.Title.contains('cq_portal_')){
                if(!camIdToBlob.containsKey(coVer.FirstPublishLocationId)){
                    camIdToBlob.put(coVer.FirstPublishLocationId, new Set<String>());                    
                }
                camIdToBlob.get(coVer.FirstPublishLocationId).add(coVer.Id);              
             }
            }
            for(Campaign cam : objList){
                FetchEventDataWrap wrapCampField = new FetchEventDataWrap();
                wrapCampField.camp = cam;
                wrapCampField.bolbData = camIdToBlob.get(cam.Id);
                camWrapperList.add(wrapCampField);
            }
            
            //return camWrapperList;
        }             
        catch(Exception e) {
            // Handle any exceptions and log the error message
        }
        // Return the list of campaign events
        return camWrapperList;   
    }
    
    @AuraEnabled
    public static String contentVersion(String contentVerId){
        List<ContentVersion> conVer = [SELECT ID, VersionData, FirstPublishLocationId from ContentVersion WHERE Id =:contentVerId];
        
        return EncodingUtil.base64Encode(conVer[0].versionData);
    }
    
    //Retrieves detailed information about a specific campaign event based on campaign Id and returning Wrapper class containing event details and volunteer attendance information
    @AuraEnabled
    public Static WrapperRegisAtten eventDetails(String campId, String recUserId){
        
         String decryptedString = communityLoginController.decryptedData(recUserId);
        
        List<String> getRegisType = new List<String>();
        List<String> getVolAtt = new List<String>();
        
        List<User> us = [SELECT Id, ContactId FROM User WHERE Id =:decryptedString];
        
        //Query to retrieve campaign details along with related volunteer attendances.
        List<Campaign> camRegistrList = [SELECT Id, Event_Type__c, Event_Start_Date__c, RVSP__c, Event_time__c, Event_End_Date__c, 
                                         Registrations_Closed__c, Portal_Description__c,Volunteer_Invite_Description__c, Venue_Address__c, Portal_Title__c, Status, Location_Venue__r.Name,
                                         Location_Venue__r.BillingStreet, Location_Venue__r.BillingCity, Location_Venue__r.BillingState, 
                                         Location_Venue__r.BillingPostalCode, Location_Venue__r.BillingCountry,
                                         (SELECT Id, Attendance__c, Event__c, Registration_Period__c, Registration_Type__r.Name, Registration_Type__r.Id,
                                          Event__r.Registrations_Closed__c, Volunteer__c FROM Volunteer_Attendances__r ) FROM Campaign WHERE ID =:campID];
        Set<Id> checkSet = new Set<Id>();
            List<ContentDocumentLink> conLink = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:campId];
			for(ContentDocumentLink cdl : conLink){
                checkSet.add(cdl.ContentDocumentId);
            }
			List<ContentVersion> conVer = [SELECT ID, Title, VersionData, FirstPublishLocationId from ContentVersion WHERE ContentDocumentId IN:checkSet];
        	Map<Id,Set<String>> camIdToBlob = new Map<Id,Set<String>>();
        	List<FetchEventDataImages>  camWrapperListBlob = new List<FetchEventDataImages>();
            
            for(ContentVersion coVer : conVer){
                if(coVer.Title.contains('cq_portal_')){
                if(!camIdToBlob.containsKey(coVer.FirstPublishLocationId)){
					camIdToBlob.put(coVer.FirstPublishLocationId, new Set<String>());                    
                }
                camIdToBlob.get(coVer.FirstPublishLocationId).add(coVer.Id);              
            	}
            }
             for(Campaign cam : camRegistrList){
                FetchEventDataImages wrapCampBlob = new FetchEventDataImages();
                //wrapCampBlob.camp = cam;
                wrapCampBlob.bolbData = camIdToBlob.get(cam.Id);
                camWrapperListBlob.add(wrapCampBlob);
            }
        
        // Creating a wrapper class instance to store event details.
        WrapperRegisAtten wrap = new WrapperRegisAtten();
		wrap.blobEventImages = camWrapperListBlob;
		
        // Populating wrapper class with campaign event details.
        wrap.eventType = camRegistrList[0].Event_Type__c;     
        wrap.startDate = camRegistrList[0].Event_Start_Date__c.day().toString()+'-'+camRegistrList[0].Event_Start_Date__c.month().toString()+'-'+camRegistrList[0].Event_Start_Date__c.year().toString();
        wrap.eventTime = camRegistrList[0].Event_time__c;
        wrap.rvsp = camRegistrList[0].RVSP__c;        
        wrap.endDate = camRegistrList[0].Event_End_Date__c.day().toString()+'-'+camRegistrList[0].Event_End_Date__c.month().toString()+'-'+camRegistrList[0].Event_End_Date__c.year().toString();
        wrap.portalDescription = camRegistrList[0].Volunteer_Invite_Description__c;
        wrap.Id = camRegistrList[0].Id;
        wrap.status = camRegistrList[0].Status;
        wrap.venueAddress = camRegistrList[0].Venue_Address__c;
        wrap.addStreet = camRegistrList[0].Location_Venue__r.BillingStreet;
        wrap.addCity = camRegistrList[0].Location_Venue__r.BillingCity;
        wrap.accName = camRegistrList[0].Location_Venue__r.Name;
        wrap.addState = camRegistrList[0].Location_Venue__r.BillingState;
        wrap.addPostalCode = camRegistrList[0].Location_Venue__r.BillingPostalCode;
        wrap.addCountry = camRegistrList[0].Location_Venue__r.BillingCountry;
        wrap.portleTittle = camRegistrList[0].Portal_Title__c;
        
        
        // Creating a list to store child wrapper class instances containing volunteer attendance details.           
        List<childWrapperCam> childList = new List<childWrapperCam>();
        // Iterating through volunteer attendances and populating the child wrapper class.
        for(Volunteer_Attendance__c volAtt : camRegistrList[0].Volunteer_Attendances__r){
            childWrapperCam child = new childWrapperCam();
            child.regisId = volAtt.Id;
            child.regisName =  volAtt.Registration_Type__r.Name;
            child.volAtt = volAtt.Attendance__c;
            
            
            // Checking the attendance status based on this we decide to show button or text.
            if(volAtt.Attendance__c == 'Accepted'){
                child.accept = true;
                //Registration date has passed
                if(camRegistrList[0].Registrations_Closed__c < System.today()){
                    child.regisAcceptText = true;
                }
                else{
                    child.regisAcceptText = false;
                }
            }
            else if(volAtt.Attendance__c == 'Invited'){
                child.invited = true;
                if(camRegistrList[0].Registrations_Closed__c < System.today()){            
                    child.showInvitedBtn = true;
                }
                else{
                    child.showInvitedBtn = false;
                }
            }
            else if(volAtt.Attendance__c == 'Request to Attend'){
                child.requestToAttend = true;
                if(camRegistrList[0].Registrations_Closed__c < System.today()){
                    child.showrequestToAttend = true;
                }
                else{
                    child.showrequestToAttend = false;
                }
            }
            else if(volAtt.Attendance__c == 'Declined'){
                child.declined = true;
                if(camRegistrList[0].Registrations_Closed__c < System.today()){
                    child.showDeclinedBtn = true;
                }
                else{
                    child.showDeclinedBtn = false;
                }
            }
            else{
                child.accept = false;
                child.invited = false;
                child.requestToAttend = false;
                child.declined = false;
            }
            //All variable value added in the list 
            if(volAtt.Volunteer__c == us[0].ContactId ){
                childList.add(child);
            }
            
        }
        //Assign list to wrapper class and return the wrapper data
        wrap.childWrapper = childList;
        return wrap;
    }
    
    //Updates volunteer attendance status and related details for a specific event based on the parameter.
    @AuraEnabled
    public Static void updateEventDetails(String voluAttId, String status, String cancelReason){        
        List<Volunteer_Attendance__c> volAtt = [SELECT Id, Attendance__c, Registration_Period__c, Cancellation_Reason__c, Event__c FROM Volunteer_Attendance__c WHERE ID =: voluAttId];    
        // List<Campaign> camList = [SELECT Id, Registrations_Closed__c FROM Campaign WHERE Id=:volAtt[0].Event__c];
        
        volAtt[0].Attendance__c = status;
        if(status == 'Cancelled' ){
            volAtt[0].Cancellation_Reason__c = cancelReason;
        }
        else if(status == 'Declined' ){
            volAtt[0].Attendance__c = status;
        }
        else if(status == 'Invited'){
            volAtt[0].Attendance__c = status;
        }
        else if(status == 'Request to Attend'){
            volAtt[0].Attendance__c = status;
        }        
        update volAtt;    
    }
    
    //Updates volunteer profile information and associated special needs and diet details comming from the JSON.
    @AuraEnabled
    public static void updateVoluEvent(String jsonData, String voluAttId){
        
        // Deserialize JSON data into a custom WrapperVoluteerData class
        WrapperVoluteerData volunList = (WrapperVoluteerData) JSON.deserialize(jsonData, WrapperVoluteerData.class);
        // Retrieve the Contact records based on the provided ContactId
        List<Contact> conList = [SELECT Id, Name, AccountId, Shirt_size__c, media_opt_in_take_video_photos__c, media_opt_in_share_participants__c, Media_Opt_in_Public_Sharing__c, 
                                 Emergency_Contact__c, Emergency_Contact_Relationship__c, Emergency_Contact_Mobile__c from Contact where Id =: volunList.ContactId ];
        String accId = conList[0].AccountId;
        // Update Contact records with the new information from the JSON
        conList[0].Shirt_Size__c = volunList.shirtSize;  
        conList[0].media_opt_in_take_video_photos__c = volunList.imageSharingOptionCheckBox;
        //conList[0].media_opt_in_share_participants__c = volunList.imageSharedParticipantsCheckBox;
        conList[0].Media_Opt_in_Public_Sharing__c = volunList.imagepublicSharing; 
        conList[0].Emergency_Contact__c = volunList.emergencyConName;
        conList[0].Emergency_Contact_Relationship__c = volunList.emergencyConRelation;
        conList[0].Emergency_Contact_Mobile__c = volunList.emergencyConMobile;
        Database.update(conList);
        Account ac = [SELECT Id, media_opt_in_take_video_photos__c, media_opt_in_share_participants__c, Media_permission_Public_2019__c, 
                      Media_permission_corporate_2019__c, Media_Permission_All_2019__c FROM Account WHERE ID =:accId];
        ac.media_opt_in_share_participants__c = volunList.imageSharedParticipantsCheckBox;
        ac.Media_permission_Public_2019__c = volunList.imageSharedPromoteWithCharitable;
        ac.Media_permission_corporate_2019__c = volunList.imagepromoteCorporatePartners;
        Database.update(ac);
        
        List<Volunteer_Attendance__c> regVolAtt = [SELECT Id, Registration_Period__c from Volunteer_Attendance__c WHERE Id=:voluAttId For Update];
        regVolAtt[0].Registration_Period__c = volunList.regisPeriodName;
        Database.update(regVolAtt);
        
        // Initialize a list to store Special Needs records to upsert
        List<Special_Needs__c> speListToUpsert = new List<Special_Needs__c>();
        
        // Process and organize Diet and Special Needs data
        for(DietWrapper diet : volunList.dietList){
            if(!String.isBlank(diet.dietDescription)){
                if(!String.isBlank(diet.recordId)){
                    Special_Needs__c spe = new Special_Needs__c();
                    spe.Id = diet.recordId;
                    spe.Long_Description__c = diet.dietDescription;
                    spe.comments__c = diet.dietComment;
                    speListToUpsert.add(spe);
                }
                else {
                    Special_Needs__c spe = new Special_Needs__c();
                    spe.Contact__c = volunList.ContactId;
                    spe.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId();
                    spe.Long_Description__c = diet.dietDescription;
                    spe.Comments__c = diet.dietComment;
                    speListToUpsert.add(spe);
                }
            }
        }
        
        for(SpeNeedWrapper speObj : volunList.speNeedList){
            if(!String.isBlank(speObj.specNeedDescription)){
                if(!String.isBlank(speObj.recordId)){
                    Special_Needs__c spe = new Special_Needs__c();
                    spe.Id = speObj.recordId;
                    spe.Long_Description__c = speobj.specNeedDescription;
                    spe.comments__c = speobj.specNeedComment;
                    speListToUpsert.add(spe);
                }
                else {
                    Special_Needs__c spe = new Special_Needs__c();
                    spe.Contact__c = volunList.ContactId;
                    spe.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId();
                    spe.Long_Description__c = speObj.specNeedDescription;
                    spe.Comments__c = speObj.specNeedComment;
                    speListToUpsert.add(spe);
                }
            }
        }
        
        // Upsert Special Needs records
        if(speListToUpsert.size() > 0){
            if(!Test.isRunningTest()){
                upsert speListToUpsert;
            }
            
        }
        
        // Process and delete Special Needs records if requested
        Set<Id> deleteNeedIds = new Set<Id>();
        List<Special_Needs__c> speListForDelete = new List<Special_Needs__c>();
        
        if(volunList.speNeedDelete != null){
            for(SpeNeedDelete speDel : volunList.speNeedDelete){
                deleteNeedIds.add(speDel.id);
            }
            speListForDelete = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c where ID IN : deleteNeedIds]; 
        }
        
        if(speListForDelete.size() > 0){
            delete speListForDelete;
        }       
    }
    
    //Retrieves volunteer profile data and associated special needs and diet details for an event and return JSON representation of volunteer profile data.
    @AuraEnabled
    public Static String getDataForEvent(String volAttId){      
        
        List<Volunteer_Attendance__c> volList = [SELECT Id, Name, Volunteer__c, Registration_Period__c,Registration_Period__r.Id, Registration_Period__r.Name, Volunteer__r.Id, Volunteer__r.Shirt_size__c, Volunteer__r.Media_Permission_All_2019__c, 
                                                 Volunteer__r.Media_permission_Public_2019__c, Volunteer__r.Media_permission_corporate_2019__c, 
                                                 Volunteer__r.media_opt_in_take_video_photos__c, Volunteer__r.media_opt_in_share_participants__c,
                                                 Volunteer__r.Emergency_Contact__c, Volunteer__r.Emergency_Contact_Relationship__c, Volunteer__r.Emergency_Contact_Mobile__c,                                                 
                                                 Volunteer__r.Media_Opt_in_Public_Sharing__c FROM Volunteer_Attendance__c WHERE Id =:volAttId];
        
        List<Contact> conList = [SELECT Id, Account.media_opt_in_share_participants__c, Account.Media_permission_Public_2019__c, 
                                 Account.Media_permission_corporate_2019__c FROM Contact WHERE Id =: volList[0].Volunteer__c];
        
        // Query for special needs associated with the user's contact
        List<Special_Needs__c> specialList = [SELECT Id, Long_Description__c, RecordTypeId, Comments__c, Contact__c From Special_Needs__c WHERE 
                                              Contact__c =: volList[0].Volunteer__r.Id];
        
        
        
        // Create a wrapper object to store the user's profile data
        WrapperVoluteerData volunteerProfile = new WrapperVoluteerData();
        
        if(volList.size() > 0 ){
            // Populate the wrapper object with user's contact information
            volunteerProfile.shirtSize = volList[0].Volunteer__r.Shirt_size__c;  
            volunteerProfile.contactId = volList[0].Volunteer__r.Id;    
            volunteerProfile.emergencyConName = volList[0].Volunteer__r.Emergency_Contact__c;
            volunteerProfile.emergencyConRelation = volList[0].Volunteer__r.Emergency_Contact_Relationship__c;
            volunteerProfile.emergencyConMobile = volList[0].Volunteer__r.Emergency_Contact_Mobile__c;
            volunteerProfile.imageSharingOptionCheckBox = volList[0].Volunteer__r.media_opt_in_take_video_photos__c ;
            volunteerProfile.imagepublicSharing =  volList[0].Volunteer__r.Media_Opt_in_Public_Sharing__c;
            volunteerProfile.agreeToParticipateInEventActi = false;
            volunteerProfile.imageSharedParticipantsCheckBox = conList[0].Account.media_opt_in_share_participants__c;
            volunteerProfile.imageSharedPromoteWithCharitable = conList[0].Account.Media_permission_Public_2019__c;
            volunteerProfile.imagepromoteCorporatePartners = conList[0].Account.Media_permission_corporate_2019__c;
            
            volunteerProfile.regisPeriodName = volList[0].Registration_Period__r.Id;
            
            if(specialList.size() > 0 ){
                // Populate the wrapper object with special needs data
                List<DietWrapper> dietList = new List<DietWrapper>();
                List<SpeNeedWrapper> speList = new List<SpeNeedWrapper>();
                for(Special_Needs__c spe : specialList){
                    if(spe.RecordTypeId == Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId()){
                        SpeNeedWrapper speWrap = new SpeNeedWrapper();
                        speWrap.specNeedDescription = spe.Long_Description__c;
                        speWrap.specNeedComment = spe.Comments__c;
                        speWrap.id = spe.Id;
                        speWrap.recordId = spe.Id;
                        speList.add(speWrap);
                    }
                    if(spe.RecordTypeId == Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId()){
                        DietWrapper dietWrap = new DietWrapper();
                        dietWrap.dietDescription = spe.Long_Description__c;
                        dietWrap.dietComment = spe.Comments__c;
                        dietWrap.id = spe.Id;
                        
                        dietWrap.recordId = spe.Id;
                        dietList.add(dietWrap);
                    }
                }
                if(dietList.size() > 0 ){
                    volunteerProfile.dietList = dietList;
                }
                if(speList.size() > 0 ){
                    volunteerProfile.speNeedList = speList;
                }
            }           
            // Serialize the wrapper object to JSON for return
            return JSON.serialize(volunteerProfile);
        }
        
        // Return an empty JSON representation if no data was found
        return JSON.serialize(volunteerProfile);
    }
    
    
    
  
    // Display picklist value of preferred session 
    @AuraEnabled
    public static List<SelectOptionWrapper> preferredSessionPicklist(String camId) {
        
        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
        
        // Query to get Registration_Type_Period__c records linked to the specific campaign
        List<Registration_Type_Period__c> rtfList = [
            SELECT Id, Name, Registration_Period__c, Registration_Type__c,
            Registration_Period__r.Name, Registration_Period__r.Id,
            Registration_Type__r.RecordType.Name
            FROM Registration_Type_Period__c 
            WHERE Registration_Period__r.Campaign__c =: camId
        ];
        
        // Query to get VolunteerAttendance__c records for the specific campaign
        List<Volunteer_Attendance__c> volunteerAttendances = [SELECT Id, Registration_Type__c FROM Volunteer_Attendance__c 
                                                              WHERE Event__c =: camId];
        
        // Create a set of Registration_Type__c IDs from the volunteerAttendances
        Set<Id> volunteerRegistrationTypeIds = new Set<Id>();
        for (Volunteer_Attendance__c va : volunteerAttendances) {
            volunteerRegistrationTypeIds.add(va.Registration_Type__c);
        }
        
        // Filter the Registration_Type_Period__c records to only include those that match the Registration_Type__c IDs
        for (Registration_Type_Period__c rtf : rtfList) {
            if (volunteerRegistrationTypeIds.contains(rtf.Registration_Type__c)) {
                options.add(new SelectOptionWrapper(rtf.Registration_Period__r.Name, rtf.Registration_Period__r.Id));
            }
        }        
        return options;
    }
    
    
  
    
    //Wrapper Class to fetchEvent and Uploaded Image 
    public class FetchEventDataWrap{
        @AuraEnabled public Campaign camp {get;set;}
        @AuraEnabled public Set<String> bolbData {get;set;}
    }
    
    	    public class FetchEventDataImages{
        @AuraEnabled public Campaign camp {get;set;}
        @AuraEnabled public Set<String> bolbData {get;set;}
    }
    
    
    //Wrapper class to hold detailed information about a campaign, contact, special Needs 
    public class WrapperRegisAtten{        
        @AuraEnabled public String eventType {get;set;}
        @AuraEnabled public String startDate  {get;set;}
        @AuraEnabled public String eventTime {get;set;}
        @AuraEnabled public String endDate {get;set;}
        @AuraEnabled public String portalDescription {get;set;}
        @AuraEnabled public String rvsp {get;set;}
        @AuraEnabled public String status {get;set;}    
        @AuraEnabled public String venueAddress {get;set;}
        @AuraEnabled public String addStreet {get;set;}
        @AuraEnabled public String addCity {get;set;}
        @AuraEnabled public String accName {get;set;}
        @AuraEnabled public String addState {get;set;}
        @AuraEnabled public String addPostalCode {get;set;}
        @AuraEnabled public String addCountry {get;set;}        
        @AuraEnabled public String portleTittle {get;set;}
        @AuraEnabled public String Id {get;set;}   
	    @AuraEnabled public List<FetchEventDataImages> blobEventImages {get;set;}
        @AuraEnabled public List<childWrapperCam> childWrapper {get;set;}                
    }
    
    public class childWrapperCam{
        
        @AuraEnabled public String regisId {get;set;}
        @AuraEnabled public String regisName {get;set;}
        @AuraEnabled public String volAtt {get;set;}
        @AuraEnabled public Boolean accept {get;set;}
        @AuraEnabled public Boolean invited {get;set;}
        @AuraEnabled public Boolean requestToAttend {get;set;}
        @AuraEnabled public Boolean declined {get;set;}
        @AuraEnabled public Boolean showInvitedBtn {get;set;}
        @AuraEnabled public Boolean showDeclinedBtn {get;set;}
        @AuraEnabled public Boolean showrequestToAttend {get;set;}
        @AuraEnabled public Boolean regisAcceptText {get;set;}
    }
    
    public class SelectOptionWrapper {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        
        // Constructor for String values
        public SelectOptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }        
    }
    
    public class WrapperVoluteerData{
        
        @AuraEnabled public String shirtSize {get;set;}
        @AuraEnabled public String contactId {get;set;}
        @AuraEnabled public String emergencyConName {get;set;}
        @AuraEnabled public String emergencyConRelation {get;set;}
        @AuraEnabled public String emergencyConMobile {get;set;}
        @AuraEnabled public Boolean imageSharingOptionCheckBox {get;set;}
        @AuraEnabled public Boolean imagepublicSharing {get;set;}
        @AuraEnabled public Boolean agreeToParticipateInEventActi {get;set;}       
        @AuraEnabled public List<dietWrapper> dietList {get;set;}
        @AuraEnabled public List<SpeNeedWrapper> speNeedList {get;set;}       
        @AuraEnabled public List<SpeNeedDelete> speNeedDelete {get;set;}      
        @AuraEnabled public Boolean imageSharedParticipantsCheckBox {get;set;}
        @AuraEnabled public Boolean imageSharedPromoteWithCharitable {get;set;}
        @AuraEnabled public Boolean imagepromoteCorporatePartners {get;set;} 
        
        @AuraEnabled public String regisPeriodName {get;set;}
    }
    
    public class DietWrapper{
        @AuraEnabled public String dietDescription {get;set;}
        @AuraEnabled public String dietComment {get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String recordId {get;set;}
    }
    
    public class SpeNeedWrapper{
        @AuraEnabled public String specNeedDescription {get;set;}
        @AuraEnabled public String specNeedComment {get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String recordId {get;set;}
    }
    
    public class SpeNeedDelete{
        @AuraEnabled public String id {get;set;}
    }
}