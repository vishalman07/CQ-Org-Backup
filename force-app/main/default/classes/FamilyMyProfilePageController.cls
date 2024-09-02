/***********************************************************************************************************************************************
* @Name         FamilyMyProfilePageController
* @Author       Amit Yadav
* @Date         01/26/2023
* @Description  Apex class is to handle profile page data this class retrive the the data from multiple object and save the data in the backend
************************************************************************************************************************************************ 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         01/26/2023       Initial Creation                                                      
******************************************************************************************* */
//Apex class is to handle family profile page data this class retrive the the data from multiple object and update the records in the backend.
public without sharing class FamilyMyProfilePageController {
    //This method is used to get family data and assigning the values in the wrapper class variable.
    @AuraEnabled
    public static String getFamilyProfiledata(String recUserId){
        String decryptedString = FamilyPortalLoginController.decryptedData(recUserId);
        // Retrieve the current user's information
        List<User> usList = new List<User>();
        usList = [SELECT Id, ContactId FROM User WHERE Id =:decryptedString];   
        // Query for the user's contact and related data
        List<Contact> conList = [SELECT Id,AccountID,  Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Account.Preferred_Event_Locations__c, Account.Family_Interests__c,
                                 Account.media_opt_in_take_video_photos__c, Account.media_opt_in_share_participants__c, Account.Media_permission_Public_2019__c, Account.Media_permission_corporate_2019__c,
                                 Account.media_opt_in_share_participants_child__c, Account.Media_permission_Public_2019_Child__c, Account.Image_Opt_In_Permission_Corporate_Child__c, Account.Home_Phone__c,
                                 Account.Mobile_Phone__c, Swimming_Ability__c, Shirt_Size__c, Name, Family_Member_Type__c, Birthdate, Image_Opt_In_photos_and_video__c, Image_Opt_In_Participant_Sharing__c, 
                                 Image_Opt_In_Permission_Public__c, Image_Opt_In_Permission_Corporate__c, Child_Image_Opt_In_Participant_Sharing__c, Child_Image_Opt_In_Permission_Corporate__c, 
                                 Child_Image_Opt_In_Permission_Public__c FROM CONTACT WHERE Id=:usList[0].ContactId AND npsp__Deceased__c = false AND Exclude_From_Portal__c = false LIMIT 1];
        // Query for special needs associated with the user's contact
        List<Special_Needs__c> specialList = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c Where Contact__c =: conList[0].Id];
        
        List<Contact> conTableList = [Select Id, AccountId, Name, Swimming_Ability__c, Shirt_Size__c FROM Contact WHERE AccountId =: conList[0].AccountId];
        // Create a wrapper object to store the user's profile data   
        WrapperVoluteerData familyProfile = new WrapperVoluteerData();
        if(conList.size() > 0 ){
            // Populate the wrapper object with user's contact information
            familyProfile.email = conList[0].Email;
            familyProfile.street = conList[0].MailingStreet;
            familyProfile.city = conList[0].MailingCity;
            familyProfile.postalCode = conList[0].MailingPostalCode;
            familyProfile.country = conList[0].MailingCountry;
            familyProfile.state = conList[0].MailingState;
            familyProfile.shirtSize = conList[0].Shirt_Size__c;
            familyProfile.swimmingAbility = conList[0].Swimming_Ability__c;
            familyProfile.name = conList[0].name;
            familyProfile.relationship = conList[0].Family_Member_Type__c;
            familyProfile.birthday = conList[0].Birthdate;
            familyProfile.conId = conList[0].Id;            
            familyProfile.preferredEventLocations = conList[0].Account.Preferred_Event_Locations__c;
            familyProfile.familyInterest = conList[0].Account.Family_Interests__c;
            familyProfile.homePhone = conList[0].Account.Home_Phone__c;
            familyProfile.mobilePhone = conList[0].Account.Mobile_Phone__c;                
            familyProfile.mediaOptInTakeVideoPhotos = conList[0].Account.media_opt_in_take_video_photos__c;
            familyProfile.mediaOptInShareParticipants = conList[0].Account.media_opt_in_share_participants__c;
            familyProfile.mediaPermissionPublic2019 = conList[0].Account.Media_permission_Public_2019__c;
            familyProfile.mediaOptInShareParticipantsChild = conList[0].Account.media_opt_in_share_participants_child__c;
            familyProfile.mediaPermissionPublic2019Child = conList[0].Account.Media_permission_Public_2019_Child__c;
            familyProfile.imageOptInPermissionCorporateChild = conList[0].Account.Image_Opt_In_Permission_Corporate_Child__c;                          
            familyProfile.mediapermissioncorporate2019 = conList[0].Account.Media_permission_corporate_2019__c;                        
        } 
        
        if(conTableList.size() > 0){
            familyProfile.contableList = contableList;          
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
                familyProfile.dietList = dietList;
            }
            if(speList.size() > 0 ){
                familyProfile.speNeedList = speList;
            }
        }
        // Serialize the wrapper object to JSON for return
        return JSON.serialize(familyProfile);        
    }
    
    //Retrieves contact and account data related to the current user for display in the component.
    @AuraEnabled
    public static List<Contact> getConDatafortable(String recUserId){
        String decryptedString = FamilyPortalLoginController.decryptedData(recUserId);
        
        List<User> usList = new List<User>();
        usList = [SELECT Id, ContactId FROM User WHERE Id = :decryptedString];
        
        List<Contact> conList = [SELECT Id, AccountId, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Account.Preferred_Event_Locations__c, Account.Family_Interests__c,
                                 Account.media_opt_in_take_video_photos__c, Account.media_opt_in_share_participants__c, Account.Media_permission_Public_2019__c, Account.Media_permission_corporate_2019__c,
                                 Account.media_opt_in_share_participants_child__c, Account.Media_permission_Public_2019_Child__c, Account.Image_Opt_In_Permission_Corporate_Child__c, Account.Home_Phone__c,
                                 Account.Mobile_Phone__c, Swimming_Ability__c, Shirt_Size__c, Name, Family_Member_Type__c, Birthdate FROM CONTACT WHERE Id=:usList[0].ContactId AND npsp__Deceased__c = false AND Exclude_From_Portal__c = false];
        
        LIST<ACCOUNT> accList = [SELECT Id, Name, (SELECT Id, Name, Shirt_Size__c, Swimming_Ability__c, Family_Member_Type__c, Birthdate FROM CONTACTS WHERE npsp__Deceased__c = false AND Exclude_From_Portal__c = false) FROM ACCOUNT WHERE Id=:conList[0].AccountId]; 
        return accList[0].Contacts;
    }
    
    //This method display the contact and special need data in the portal
    @AuraEnabled
    public static String getTableBtnData(String contId){
        
        List<Contact> conList = [Select Id, Name, Shirt_Size__c, Swimming_Ability__c FROM Contact WHERE Id=:contId];
        List<Special_Needs__c> specialList = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c Where Contact__c =: conList[0].Id];
        
        WrapperVoluteerData tableProfile = new WrapperVoluteerData();
        
        tableProfile.shirtSize = conList[0].Shirt_Size__c;
        tableProfile.swimmingAbility = conList[0].Swimming_Ability__c;
        
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
                    system.debug('Check table diet---->'+speList);
                }
                if(spe.RecordTypeId == Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId()){
                    DietWrapper dietWrap = new DietWrapper();
                    dietWrap.dietDescription = spe.Long_Description__c;
                    dietWrap.dietComment = spe.Comments__c;
                    dietWrap.id = spe.Id;
                    dietWrap.recordId = spe.Id;
                    dietList.add(dietWrap);
                    system.debug('Check table diet---->'+dietList);
                }
            }
            if(dietList.size() > 0 ){
                tableProfile.dietList = dietList;
                system.debug('Check table diet---->'+ tableProfile.dietList);
            }
            if(speList.size() > 0 ){
                tableProfile.speNeedList = speList;
                system.debug('Check table Speial---->'+ tableProfile.speNeedList);
            }
        }
        return JSON.serialize(tableProfile);         
    }
    
    
    //This method is to retrive and return the prefered event location picklist value.
    @AuraEnabled(cacheable=true)
    public Static List<String> locationInProfile(){
        List<String> pickListValuesList = new List<String>();
        
        // Describe the field to get its metadata
        Schema.DescribeFieldResult fieldResult = Account.Preferred_Event_Locations__c.getDescribe();
        
        // Get the picklist values
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        // Iterate through the picklist values and add them to the list
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getValue());
        }             
        return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public Static List<String> familyInterestData(){
        List<String> familypickListValuesList = new List<String>();        
        // Describe the field to get its metadata
        Schema.DescribeFieldResult fieldResult = Account.Family_Interests__c.getDescribe();        
        // Get the picklist values
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for (Schema.PicklistEntry pickListVal : ple) {
            familypickListValuesList.add(pickListVal.getValue());
        }     
        
        return familypickListValuesList;
    }
    
    @AuraEnabled
    public static String savefamilyData(String jsonData, String recUserId){
        
        System.debug('jsonData' + jsonData);
        // Deserialize the JSON data into a WrapperVoluteerData object
        WrapperVoluteerData familyWrap = (WrapperVoluteerData) JSON.deserialize(jsonData, WrapperVoluteerData.class); 
        String decryptedString = FamilyPortalLoginController.decryptedData(recUserId);
        // Query for the current user's contact information
        List<User> uList = new List<User>([SELECT Id, ContactId FROM User WHERE Id = :decryptedString]);
        List<Contact> conList = [SELECT Id, AccountId, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Account.Preferred_Event_Locations__c, Account.Family_Interests__c,
                                 Account.media_opt_in_take_video_photos__c, Account.media_opt_in_share_participants__c, Account.Media_permission_Public_2019__c, Account.Media_permission_corporate_2019__c,
                                 Account.media_opt_in_share_participants_child__c, Account.Media_permission_Public_2019_Child__c, Account.Image_Opt_In_Permission_Corporate_Child__c, Account.Home_Phone__c,
                                 Account.Mobile_Phone__c, Swimming_Ability__c, Shirt_Size__c, Name, Family_Member_Type__c, Birthdate, 
                                 Image_Opt_In_photos_and_video__c, Image_Opt_In_Participant_Sharing__c, 
                                 Image_Opt_In_Permission_Public__c, Image_Opt_In_Permission_Corporate__c, Child_Image_Opt_In_Participant_Sharing__c, Child_Image_Opt_In_Permission_Corporate__c, 
                                 Child_Image_Opt_In_Permission_Public__c FROM CONTACT WHERE Id = :uList[0].ContactId LIMIT 1];
        
        //Assigning the wrapper variable data to update contacts
        conList[0].Email = familyWrap.email;
        conList[0].MailingStreet = familyWrap.street;
        conList[0].MailingCity = familyWrap.city;
        conList[0].MailingPostalCode = familyWrap.postalCode;
        conList[0].MailingCountry = familyWrap.country;
        conList[0].MailingState = familyWrap.state;
        conList[0].Shirt_Size__c = familyWrap.shirtSize;
        conList[0].Swimming_Ability__c = familyWrap.swimmingAbility;
        conList[0].Family_Member_Type__c = familyWrap.relationship;        
        conList[0].Birthdate = familyWrap.birthday;
        conList[0].Id = familyWrap.conId;
        
        conList[0].Account.Preferred_Event_Locations__c = familyWrap.preferredEventLocations;
        conList[0].Account.Family_Interests__c = familyWrap.familyInterest;
        conList[0].Account.Home_Phone__c = familyWrap.homePhone;
        conList[0].Account.Mobile_Phone__c = familyWrap.mobilePhone;
        
        conList[0].Account.media_opt_in_take_video_photos__c = familyWrap.mediaOptInTakeVideoPhotos;
        conList[0].Account.media_opt_in_share_participants__c = familyWrap.mediaOptInShareParticipants;
        conList[0].Account.Media_permission_Public_2019__c = familyWrap.mediaPermissionPublic2019;
        conList[0].Account.media_opt_in_share_participants_child__c = familyWrap.mediaOptInShareParticipantsChild;
        conList[0].Account.Media_permission_Public_2019_Child__c = familyWrap.mediaPermissionPublic2019Child;
        conList[0].Account.Image_Opt_In_Permission_Corporate_Child__c = familyWrap.imageOptInPermissionCorporateChild;        
        conList[0].Account.Media_permission_corporate_2019__c =  familyWrap.mediapermissioncorporate2019;
        
        /* conList[0].Image_Opt_In_photos_and_video__c = familyWrap.imageOptInphotosandvideo;
        conList[0].Image_Opt_In_Participant_Sharing__c = familyWrap.imageOptInParticipantSharing;
        conList[0].Image_Opt_In_Permission_Public__c = familyWrap.imageOptInPermissionPublic;
        conList[0].Image_Opt_In_Permission_Corporate__c = familyWrap.
        conList[0].Child_Image_Opt_In_Participant_Sharing__c = familyWrap.
        conList[0].Child_Image_Opt_In_Permission_Corporate__c = familyWrap.
        conList[0].Child_Image_Opt_In_Permission_Public__c = familyWrap.*/
        
        update conList;
        update conList[0].Account;
        return 'Family Data Saved';
    }
    
    //Updates the user's profile data based on the provided JSON representation.
    @AuraEnabled
    public static String updatetableData(String tableJsonData , String contId){
        System.debug('tableJsonData' + tableJsonData);
        
        WrapperVoluteerData tableWrap = (WrapperVoluteerData) JSON.deserialize(tableJsonData, WrapperVoluteerData.class);
        
        List<Contact> con = [Select Id, Name, Shirt_Size__c, Swimming_Ability__c FROM Contact WHERE Id =: contId];
        List<Special_Needs__c> specialList = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c Where Contact__c =: con[0].Id];
        // Initialize a list to store Special Needs records to upsert
        List<Special_Needs__c> speListToUpsert = new List<Special_Needs__c>();
        
        //Adding the special need and dietary record in the list and upserting it.
        for(DietWrapper diet : tableWrap.dietList){
            if(!String.isBlank(diet.dietDescription)){
                if(!String.isBlank(diet.recordId)){
                    Special_Needs__c spe = new Special_Needs__c();
                    spe.Id = diet.recordId;
                    spe.Long_Description__c = diet.dietDescription;
                    spe.comments__c = diet.dietComment;
                    speListToUpsert.add(spe);
                }
                else{
                    Special_Needs__c spe = new Special_Needs__c();
                    spe.Contact__c = con[0].Id;
                    spe.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId();
                    spe.Long_Description__c = diet.dietDescription;
                    spe.Comments__c = diet.dietComment;
                    speListToUpsert.add(spe);
                }
            }
        }
        
        for(SpeNeedWrapper speNeed : tableWrap.speNeedList){
            if(!String.isBlank(speNeed.specNeedDescription)){
                if(!String.isBlank(speNeed.recordId)){
                    Special_Needs__c spe = new Special_Needs__c();
                    spe.Id = speNeed.recordId;
                    spe.Long_Description__c = speNeed.specNeedDescription;
                    spe.comments__c = speNeed.specNeedComment;
                    speListToUpsert.add(spe);
                }
                else{
                    Special_Needs__c spe = new Special_Needs__c();
                    spe.Contact__c = con[0].Id;
                    spe.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId();
                    spe.Long_Description__c = speNeed.specNeedDescription;
                    spe.Comments__c = speNeed.specNeedComment;
                    speListToUpsert.add(spe);
                }
            }
        }
        
        if(speListToUpsert.size() > 0){
            upsert speListToUpsert;
        } 
        
        Set<Id> deleteNeedIds = new Set<Id>();
        List<Special_Needs__c> speListForDelete = new List<Special_Needs__c>();
        
        if(tableWrap.speNeedDelete != null){
            for(speNeedDelete speDel : tableWrap.speNeedDelete){
                deleteNeedIds.add(speDel.id);
            }
            speListForDelete = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c where ID IN : deleteNeedIds ];
        }
        
        if(speListForDelete.size() > 0){           
            delete speListForDelete;                     
        }
        // Update user's contact information
        con[0].Shirt_Size__c = tableWrap.shirtSize;
        con[0].Swimming_Ability__c = tableWrap.swimmingAbility;
        update con;
        
        return 'Table Data Saved';
    }
    
    //This method return the home page object record based on certain criteria 
    @AuraEnabled
    public static Page__c homePageContect(){        
        Page__c pg = [Select Id, Name, Site__r.Name, Content__c FROM Page__c WHERE NAME ='Home Page' AND Site__r.Name = 'Camp Quality Families'];
        return pg;
    }
    
    
    //This method allows a user to contact support and calling method from another class and return message.
    @AuraEnabled
    public static String contactUs(String subject, String details, String reason, String userId){
        // Create a support case and get a success message
        String successMsg = PortalContactUs.createCase(subject,details,reason, userId);
        return successMsg;
    }
   
    //Wrapper class variable
    public class WrapperVoluteerData{
        
        //Contact's field
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String street {get;set;}
        @AuraEnabled public String postalCode {get;set;}
        @AuraEnabled public String country {get;set;}
        @AuraEnabled public String city {get;set;}
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String relationship {get;set;}
        @AuraEnabled public Date birthday {get;set;}
        @AuraEnabled public String conId {get;set;}
        
        
        //Account's field
        @AuraEnabled public String preferredEventLocations {get;set;}
        @AuraEnabled public String familyInterest {get;set;}
        @AuraEnabled public String homePhone {get;set;}
        @AuraEnabled public String mobilePhone {get;set;}
        @AuraEnabled public String shirtSize {get;set;}
        @AuraEnabled public String swimmingAbility {get;set;}
        
        //Account's checkboxes
        @AuraEnabled public Boolean mediaOptInTakeVideoPhotos {get;set;}
        @AuraEnabled public Boolean mediaOptInShareParticipants {get;set;}
        @Auraenabled public Boolean mediaPermissionPublic2019 {get;set;}
        @Auraenabled public Boolean mediaOptInShareParticipantsChild {get;set;}
        @Auraenabled public Boolean mediaPermissionPublic2019Child {get;set;}
        @Auraenabled public Boolean imageOptInPermissionCorporateChild {get;set;}        
        @Auraenabled public Boolean mediapermissioncorporate2019 {get;set;}
        
        //Contact checkbox
         /*@AuraEnabled public Boolean imageOptInphotosandvideo {get;set;}
        @AuraEnabled public Boolean imageOptInParticipantSharing {get;set;}
        @AuraEnabled public Boolean imageOptInPermissionPublic {get;set;}
        @AuraEnabled public Boolean imageOptInPermissionCorporate {get;set;}
        @AuraEnabled public Boolean childImageOptInParticipantSharing {get;set;}
        @AuraEnabled public Boolean childImageOptInPermissionCorporate {get;set;}
        @AuraEnabled public Boolean childImageOptInPermissionPublic {get;set;}*/
        
        
        // Lists for diet and special needs data
        @AuraEnabled public List<dietWrapper> dietList {get;set;}
        @AuraEnabled public List<SpeNeedWrapper> speNeedList {get;set;}
        
        // List for special needs to delete
        @AuraEnabled public List<SpeNeedDelete> speNeedDelete {get;set;}
        
        //Contact data for table
        @AuraEnabled public List<Contact> contableList {get;set;}         
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
    
    public class ContableWrapper{
        @AuraEnabled public String conSwim {get;set;}
        @AuraEnabled public String conShirtSize {get;set;}
        @AuraEnabled public String contId {get;set;}                
    }
}