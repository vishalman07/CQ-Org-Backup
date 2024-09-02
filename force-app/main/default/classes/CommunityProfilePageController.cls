/********************************************************************************************
* @Name         CommunityProfilePageController
* @Author       Amit Yadav
* @Date         10/16/2023
* @Description  This class handle the valunteer profile data for protal site  
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         10/16/2023         Initial Creation                                                      
******************************************************************************************* */
//This class handle the valunteer profile data for protal site 
public without sharing class CommunityProfilePageController {
    
    /*
	 Retrieves a list of picklist values for the 'Preferred_Event_Locations__c' field on the 'Contact' object.
	 This method is exposed as an AuraEnabled action and can be used in Lightning components.
	 @return List of string values representing the picklist options.
	*/
    @AuraEnabled(cacheable=true)
    public Static List<String> locationInProfile(){
        List<String> pickListValuesList = new List<String>();
        
        // Describe the field to get its metadata
        Schema.DescribeFieldResult fieldResult = Contact.Preferred_Event_Locations__c.getDescribe();
        
        // Get the picklist values
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        // Iterate through the picklist values and add them to the list
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getValue());
        }            
        return pickListValuesList;
    }
    
    /*
    Retrieves the user's avatar data as a base64-encoded string.
    This method is exposed as an AuraEnabled action and can be used in Lightning components.
    @return Base64-encoded avatar data or an empty string if no avatar is found.
	*/
    @AuraEnabled(cacheable=true)
    public Static String userAvatar(String recUserId){       
        // Initialize variables       
        String imgData;
        List<ContentVersion> conVersion = new List<ContentVersion>();        
        // Retrieve the current user's information
        List<User> uList = new List<User>([SELECT Id, ContactId FROM User WHERE Id = :recUserId]);
        
        // Query for user's profile image attachments
        List<Attachment__c> attaches = [SELECT Id, AttachmentID__c, Content_Type__c FROM Attachment__c 
                                        WHERE Attachment_Type__c = 'Profile Image' 
                                        AND Contact__c = :uList[0].ContactId 
                                        AND (Show_in_Portal__c = 'Volunteer' OR Show_in_Portal__c = 'Both')];
        
        // Check if profile image attachments exist
        if (!attaches.isEmpty()) {
            // Query for ContentVersion to obtain avatar data
            conVersion = [SELECT Id, FileType, Title, TagCsv, VersionData FROM ContentVersion WHERE Id = :attaches[0].AttachmentID__c];
            
            // Check if ContentVersion records were found
            if (!conVersion.isEmpty()) {
                // Encode the avatar data as base64
                imgData = EncodingUtil.Base64Encode(conVersion[0].VersionData);
            }
        }              
        return imgData; // Return the base64-encoded avatar data (or an empty string if not found)
    }
    
    /*
    Uploads and manages a user's profile image.
    This method is exposed as an AuraEnabled action and can be used in Lightning components.
    @param imgData Base64-encoded image data to upload.
    @return A status message, such as 'image Upload' or 'image upload'.
    */
    @AuraEnabled
    public Static String imageUpload(String imgData){
        
        // Retrieve the current user's information
        List<User> uList = new List<User>([SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()]);
        
        // Query for user's profile image attachments
        List<Attachment__c> attaches = [SELECT Id, AttachmentID__c, Content_Type__c FROM Attachment__c 
                                        WHERE Attachment_Type__c = 'Profile Image' 
                                        AND Contact__c = :uList[0].ContactId 
                                        AND (Show_in_Portal__c = 'Volunteer' OR Show_in_Portal__c = 'Both')];
        
        // Create a new ContentVersion record for the uploaded image
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Profile Image';
        cv.VersionData = EncodingUtil.base64Decode(imgData);
        cv.PathOnClient = uList[0].Name + '.png';
        cv.FirstPublishLocationId = Network.getNetworkId();
        
        // Insert the ContentVersion record to store the image
        if(!Test.isRunningTest()) {
            insert cv;
        }
        
        // Check if profile image attachments exist
        if (attaches.isEmpty()) {
            // Create a new Attachment__c record to associate with the user's profile
            Attachment__c attache = new Attachment__c();
            attache.AttachmentID__c = (String) cv.Id;
            attache.Attachment_Type__c = 'Profile Image';
            attache.Content_Type__c = 'Attachment';
            attache.Contact__c = uList[0].ContactId;
            attache.Show_in_Portal__c = 'Volunteer';
            
            // Insert the Attachment__c record
            insert attache;                       
            return 'image Upload';
        } else {
            // Update the existing Attachment__c record with the new ContentVersion ID
            attaches[0].AttachmentID__c = (String) cv.Id;
            attaches[0].Attachment_Type__c = 'Profile Image';
            attaches[0].Content_Type__c = 'Attachment';
            
            // Update the Attachment__c record
            update attaches[0];                      
            return 'image upload';
        }
    }
    /**
    Retrieves the profile data of the current user, including contact and related information.
    This method is exposed as an AuraEnabled action and can be used in Lightning components.
    @return A JSON-serialized representation of the user's profile data.
	*/
    @AuraEnabled
    public Static String getProfiledata(String recUserId){
        System.debug('recUserId--------------' + recUserId);
       /* String encryptedString = recUserId;
        Blob cipherText = EncodingUtil.base64Decode(encryptedString);
        Blob exampleIv = Blob.valueOf('Example of IV123');
        Blob key = Crypto.generateAesKey(128);
        Blob decrypted = Crypto.decrypt('AES128', key, exampleIv, cipherText);*/
        String decryptedString = communityLoginController.decryptedData(recUserId);
        System.debug('--decryptedString-----'+ decryptedString);
        // Retrieve the current user's information
        List<User> uList = new List<User>([SELECT Id, ContactId FROM User WHERE Id =:decryptedString]);
        System.debug('uList------------'+ uList);
        // Query for the user's contact and related data
        List<Contact> con = [SELECT Id, Name, FirstName, LastName, Email, HomePhone, MailingStreet, MailingCity,
                             MailingState, MailingPostalCode, MailingCountry, Preferred_Event_Locations__c, RecordType.DeveloperName,
                             Swimming_Ability__c, Shirt_Size__c, Emergency_Contact__c, Emergency_Contact_Phone__c,
                             Emergency_Contact_Mobile__c, Emergency_Contact_Relationship__c, Account.Name, Birthdate,
                             MobilePhone, Media_Permission_Denied__c, Media_Permission_Functions__c, Requests_no_Marketing_Materials__c, Requests_No_Newsletter__c,
                             Media_Permission_Interviews__c, Media_Permission_Photos__c, Media_Permission_Photo_Share__c, media_opt_in_share_participants__c, media_opt_in_take_video_photos__c, Media_Opt_in_Public_Sharing__c,
                             Media_Permission_Pub__c, AccountId, Account.OwnerId, Account.Phone, Account.BillingStreet, Media_Permission_All_2019__c, Media_permission_Public_2019__c, Media_permission_corporate_2019__c,
                             Account.BillingCity, Account.BillingPostalCode, Account.BillingState, Contact.Volunteer_Last_Training_Date__c, Account.media_opt_in_share_participants__c, Account.Media_permission_Public_2019__c, 
                             Account.Media_permission_corporate_2019__c, Account.media_opt_in_take_video_photos__c, Account.Media_Permission_All_2019__c  
                             FROM Contact WHERE Id = :uList[0].ContactId];
        System.debug('con----------'+ uList[0].ContactId);
        List<Volunteer_Skill__c> volSkill = [Select Id, Expires__c, Volunteer__c, RecordTypeId From Volunteer_Skill__c where Volunteer__c = : con[0].Id And recordTypeId = : Schema.SObjectType.Volunteer_Skill__c.getRecordTypeInfosByDeveloperName().get('Working_With_Children_Check').getRecordTypeId() Limit 1]; 
        // Query for special needs associated with the user's contact
        List<Special_Needs__c> specialList = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c Where Contact__c =: con[0].Id];
        // Query for Volunteer Type associated with the user's contact
        List<Volunteer_Type__c> volType = [SELECT Id, Volunteer_Type__c, Volunteer_Status__c from Volunteer_Type__c WHERE Volunteer__c =:con[0].Id AND Volunteer_Status__c = 'Active'];      
        // Create a wrapper object to store the user's profile data
        WrapperVoluteerData volunteerProfile = new WrapperVoluteerData();
        
        if(con.size() > 0 ){
            // Populate the wrapper object with user's contact information
            volunteerProfile.emailAddress = con[0].Email;
            volunteerProfile.homePhone = con[0].HomePhone;
            volunteerProfile.swimmingAbility = con[0].Swimming_Ability__c;
            volunteerProfile.address = con[0].MailingStreet;
            volunteerProfile.mobilePhone = con[0].MobilePhone;
            volunteerProfile.shirtSize = con[0].Shirt_Size__c;
            volunteerProfile.suburb = con[0].MailingCity;
            volunteerProfile.preferredEventLocations = con[0].Preferred_Event_Locations__c;
            volunteerProfile.state = con[0].MailingState;
            volunteerProfile.postcode = con[0].MailingPostalCode;           
            volunteerProfile.imagePermissionCheckBox = con[0].Account.media_opt_in_take_video_photos__c;
            volunteerProfile.imageBelowways = con[0].Account.Media_Permission_All_2019__c;
            volunteerProfile.imageSharedParticipantsCheckBox = con[0].Account.media_opt_in_share_participants__c;
            volunteerProfile.imageSharedPromoteWithCharitable = con[0].Account.Media_permission_Public_2019__c;
            volunteerProfile.imagepromoteCorporatePartners = con[0].Account.Media_permission_corporate_2019__c;            
            if(volType.size() > 0){
                volunteerProfile.volList = volType;
            }          
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
            if(volSkill.size() > 0){
                volunteerProfile.expires = String.valueOf(volSkill[0].Expires__c);
            }
            
            // Serialize the wrapper object to JSON for return
            return JSON.serialize(volunteerProfile);
        }
        
        // Return an empty JSON representation if no data was found        
        return JSON.serialize(volunteerProfile);
    }
    
    /*
	Updates the user's profile data based on the provided JSON representation.
	This method is exposed as an AuraEnabled action and can be used in Lightning components.
	@param jsonStr The JSON string representing the user's profile data to update.
	@return A message indicating the success of the data update.
   */
    @AuraEnabled
    public static String saveData(String jsonStr, String recUserId){          
        // Deserialize the JSON data into a WrapperVoluteerData object
        WrapperVoluteerData volunList = (WrapperVoluteerData) JSON.deserialize(jsonStr, WrapperVoluteerData.class);
        
        String decryptedString = communityLoginController.decryptedData(recUserId);
        // Query for the current user's contact information
        List<User> uList = new List<User>([SELECT Id, ContactId FROM User WHERE Id = :decryptedString]);
        Contact con = [SELECT Id, Name, FirstName, LastName, Email, HomePhone, MailingStreet, MailingCity,
                       MailingState, MailingPostalCode, MailingCountry, Preferred_Event_Locations__c, RecordType.DeveloperName,
                       Swimming_Ability__c, Shirt_Size__c, Emergency_Contact__c, Emergency_Contact_Phone__c,
                       Emergency_Contact_Mobile__c, Emergency_Contact_Relationship__c, Account.Name, Birthdate,
                       MobilePhone, Media_Permission_Denied__c, Media_Permission_Functions__c, Requests_no_Marketing_Materials__c, Requests_No_Newsletter__c,
                       Media_Permission_Interviews__c, Media_Permission_Photos__c, Media_Permission_Photo_Share__c, media_opt_in_share_participants__c, media_opt_in_take_video_photos__c, Media_Opt_in_Public_Sharing__c,
                       Media_Permission_Pub__c, AccountId FROM Contact WHERE Id = :uList[0].ContactId LIMIT 1];        
      
        // Initialize a list to store Special Needs records to upsert
        List<Special_Needs__c> speListToUpsert = new List<Special_Needs__c>();
        
        // Process and organize Diet and Special Needs data
        if(volunList.dietList.size()>0 && volunList.dietList !=null){
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
                    spe.Contact__c = con.Id;
                    spe.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId();
                    spe.Long_Description__c = diet.dietDescription;
                    spe.Comments__c = diet.dietComment;
                    speListToUpsert.add(spe);
                }
            }
        }
         }
		
        
        if(volunList.speNeedList.size()>0 && volunList.speNeedList!=null){
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
                    spe.Contact__c = con.Id;
                    spe.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId();
                    spe.Long_Description__c = speObj.specNeedDescription;
                    spe.Comments__c = speObj.specNeedComment;
                    speListToUpsert.add(spe);
                }
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
            speListForDelete = [SELECT Id, Long_Description__c, RecordTypeId, Comments__c, Contact__c From Special_Needs__c where ID IN : deleteNeedIds]; 
        }
        
        
        if(speListForDelete.size() > 0){
            if(!Test.isRunningTest()){
                delete speListForDelete;
            }            
        }
        
        // Update user's contact information
        con.Email = volunList.emailAddress;
        con.HomePhone = volunList.homePhone;
        con.MailingStreet = volunList.address;
        con.MailingCity = volunList.suburb;
        con.MailingState = volunList.state;
        con.MailingPostalCode = volunList.postcode;
        con.Preferred_Event_Locations__c = volunList.preferredEventLocations;
        con.MobilePhone = volunList.mobilePhone;
        con.Shirt_Size__c = volunList.shirtSize;
        con.Swimming_Ability__c = volunList.swimmingAbility;
        
        Account ac = [SELECT Id, media_opt_in_take_video_photos__c, media_opt_in_share_participants__c, Media_permission_Public_2019__c, 
                      Media_permission_corporate_2019__c, Media_Permission_All_2019__c FROM Account WHERE ID =:con.AccountId LIMIT 1];
        
        ac.media_opt_in_take_video_photos__c = volunList.imagePermissionCheckBox;
        ac.Media_Permission_All_2019__c = volunList.imageBelowways;
        ac.media_opt_in_share_participants__c = volunList.imageSharedParticipantsCheckBox;
        ac.Media_permission_Public_2019__c = volunList.imageSharedPromoteWithCharitable;
        ac.Media_permission_corporate_2019__c = volunList.imagepromoteCorporatePartners;
        
        update con;
        System.debug('Con updaated');
        update ac;
        System.debug('Ac updaated');
        return 'Data Updated';
    }
    
    
    
    /*A wrapper class used to encapsulate volunteer profile data for communication between the client and server*/
    public class WrapperVoluteerData{
        
        // User's contact information
        @AuraEnabled public String emailAddress {get;set;}
        @AuraEnabled public String homePhone {get;set;}
        @AuraEnabled public String swimmingAbility {get;set;}
        @AuraEnabled public String address {get;set;}
        @AuraEnabled public String mobilePhone{get;set;}
        @AuraEnabled public String shirtSize {get;set;}
        @AuraEnabled public String suburb {get;set;}
        @AuraEnabled public String preferredEventLocations {get;set;} 
        
        // Image permissions and sharing options
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public String postcode {get;set;}
        @AuraEnabled public Boolean imagePermissionCheckBox {get;set;}
        @AuraEnabled public Boolean imageSharingOptionCheckBox {get;set;}
        @AuraEnabled public Boolean imageSharedParticipantsCheckBox {get;set;}
        @AuraEnabled public Boolean imageSharedPromoteWithCharitable {get;set;}
        @AuraEnabled public Boolean imagepromoteCorporatePartners {get;set;} 
        @AuraEnabled public Boolean imageBelowways {get;set;} 
        
        // Lists for diet and special needs data
        @AuraEnabled public List<dietWrapper> dietList {get;set;}
        @AuraEnabled public List<SpeNeedWrapper> speNeedList {get;set;}
        
        // List for special needs to delete
        @AuraEnabled public List<SpeNeedDelete> speNeedDelete {get;set;}
        
        //value for volunteer Skill
        @AuraEnabled public String expires {get;set;} 
        
        //Value for volunteer type
        @AuraEnabled public List<Volunteer_Type__c> volList{get;set;}
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