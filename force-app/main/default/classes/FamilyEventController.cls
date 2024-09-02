/********************************************************************************************
* @Name         FamilyEventController
* @Author       Amit Yadav
* @Date         12/13/2023
* @Description  Apex class to handle family event-related functionality for the family portal.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/13/2023        Initial Creation                                                      
******************************************************************************************* */
//Apex class to handle family event-related functionality for the family portal.
public without sharing class FamilyEventController {
    //fetchEvents method retrieves a list of Campaigns based on certain criteria and return the list of campaign record.
    @AuraEnabled
    public static List<FetchEventDataWrap> fetchEvents(String recUserId){
	
		String decryptedString = FamilyPortalLoginController.decryptedData(recUserId);
        // List to store the retrieved Campaign records.
        List<Campaign> objList = new List<Campaign>();  
        Set<Id> setOfCamId = new Set<Id>();
        Set<Id> checkSet = new Set<Id>();
        List<FetchEventDataWrap> camWrapperList = new List<FetchEventDataWrap>();
        // Filter conditions for Family_Attendance__c related to the campaign.
        String filterAttendance = ' AND (FA_00000__c = \'Invited\' OR FA_00000__c = \'Request to Attend\' OR FA_00000__c = \'Accepted\' OR FA_00000__c = \'Attended\') ';
        // Retrieve the current user's information.
        List<User> us = [Select Id,ContactId from user where Id =:decryptedString];
        // Retrieve the Contact associated with the user.
        Contact con = [Select Id,AccountId FROM Contact Where Id =:us[0].ContactId];
        // Describe the Campaign object to get its fields.
        Schema.DescribeSObjectResult objDescribe = Campaign.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        // Construct the initial part of the dynamic SOQL query.
        String theQuery = 'SELECT ';
        // Iterate over the fields of the Campaign object and add them to the query.
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        theQuery += ' FROM Campaign WHERE Registrations_Open__c <= TODAY ';
        theQuery += 'AND (Status = \'Approved for portal and invites\' OR Status = \'Snapshot Approved\' OR Status = \'Active\')';
        // Get the current date
        Datetime todayDate = Datetime.now();
        theQuery += ' AND EndDate  >= TODAY' ;
        // Add conditions to filter Campaigns based on Family_Attendance__c related to the Contact's Account.
        String AccountId = con.AccountId;
        theQuery += ' AND Id IN (SELECT Event__c FROM Family_Attendance__c WHERE Family__c =: AccountId ' + filterAttendance + ') ';        
        theQuery += ' ORDER BY CreatedDate';
        System.debug('theQuery---'+ theQuery);
        try {
            // Execute the dynamic SOQL query and store the results in the objList.            
            objList = Database.query(theQuery);
            System.debug(objList);
            for(Campaign cam : objList){
                //FetchEventDataWrap wrapCampField = new FetchEventDataWrap();
                setOfCamId.add(cam.Id);
            }
            system.debug(setOfCamId);
            
            //List<ContentDocument> coDocment = [SELECT ID, LatestPublishedVersion.Versiondata from ContentDocument];
            List<ContentDocumentLink> conLink = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:setOfCamId];
            System.debug('Document Link --->' + conLink);
            for(ContentDocumentLink cdl : conLink){
                checkSet.add(cdl.ContentDocumentId);
            }
            
            List<ContentVersion> conVer = [SELECT ID, Title, VersionData, FirstPublishLocationId from ContentVersion WHERE ContentDocumentId IN:checkSet];
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
            // Handle any exceptions that occur during the execution of the query.
            System.debug('Error ' + e.getMessage());
        }
        // Return the list of Campaign records.
        return camWrapperList;   
    }
    
    @AuraEnabled
    public static String contentVersion(String contentVerId){
        List<ContentVersion> conVer = [SELECT ID, VersionData, FirstPublishLocationId from ContentVersion WHERE Id =:contentVerId];
        
        return EncodingUtil.base64Encode(conVer[0].versionData);
    }
    
    @AuraEnabled
    public static String contentVersionforEvent(String contentVerId){
        List<ContentVersion> conVer = [SELECT ID, VersionData, FirstPublishLocationId from ContentVersion WHERE Id =:contentVerId];
        
        return EncodingUtil.base64Encode(conVer[0].versionData);
    }
    
    //familyEventdetails method retrieves details of a family event based on the provided Campaign Id and return wrapper class data
    @AuraEnabled
    public Static WrapperRegisAtten familyEventdetails(String campId, String recUserId){
        System.debug('Check 111 campId--'+ campId);
        System.debug('Check 111 recUserId--'+ recUserId);
        String decryptedString = FamilyPortalLoginController.decryptedData(recUserId);
        List<User> us = [SELECT Id, ContactId FROM User WHERE Id =:decryptedString];        
        List<Contact> con = [SELECT Id, AccountId FROM Contact WHERE Id=:us[0].ContactId];        
        // Query to retrieve Campaign and related Family_Attendance__c records.
        List<Campaign> camRegistrList = [Select Id, Venue_Address__c, Event_Type__c,RVSP__c, Event_Start_Date__c, StartDate, EndDate,Event_time__c, Event_End_Date__c,
                                         Registrations_Closed__c, Portal_Description__c, Status, Portal_Title__c, Location_Venue__r.BillingStreet, 
                                         Location_Venue__r.BillingCity, Location_Venue__r.BillingState,RecordType.DeveloperName, 
                                         Location_Venue__r.BillingPostalCode, Location_Venue__r.BillingCountry, Location_Venue__r.Name,
                                         (Select Id,FA_00000__c,Family__c,Event__c,Registration_Type__r.Name , Registration_Type__r.Id, 
                                          Event__r.Registrations_Closed__c  from Family_Attendances__r) from Campaign WHERE ID =:campID]; 
        
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
        
        
        // Create a WrapperRegisAtten object to store details.
        WrapperRegisAtten wrap = new WrapperRegisAtten();
        if(camWrapperListBlob !=null){                  
        	wrap.blobEventImages = camWrapperListBlob;
		}
        wrap.eventType = camRegistrList[0].Event_Type__c;       
        wrap.startDate = camRegistrList[0].Event_Start_Date__c.day().toString()+'-'+camRegistrList[0].Event_Start_Date__c.month().toString()+'-'+camRegistrList[0].Event_Start_Date__c.year().toString();
        wrap.endDate = camRegistrList[0].Event_End_Date__c.day().toString()+'-'+camRegistrList[0].Event_End_Date__c.month().toString()+'-'+camRegistrList[0].Event_End_Date__c.year().toString();        
        wrap.RSVP = camRegistrList[0].RVSP__c;
        wrap.eventTime = camRegistrList[0].Event_time__c;
        wrap.Description = camRegistrList[0].Portal_Description__c;
        wrap.Id = camRegistrList[0].Id;
        wrap.Venue_Address = camRegistrList[0].Venue_Address__c; 
        wrap.portalTitle =  camRegistrList[0].Portal_Title__c;
        wrap.addStreet = camRegistrList[0].Location_Venue__r.BillingStreet;
        wrap.addCity = camRegistrList[0].Location_Venue__r.BillingCity;
        wrap.accName = camRegistrList[0].Location_Venue__r.Name;
        wrap.addState = camRegistrList[0].Location_Venue__r.BillingState;
        wrap.addPostalCode = camRegistrList[0].Location_Venue__r.BillingPostalCode;
        wrap.addCountry = camRegistrList[0].Location_Venue__r.BillingCountry;
        wrap.portalDescription = camRegistrList[0].Portal_Description__c;
        wrap.recordTypeName = camRegistrList[0].RecordType.DeveloperName;

        // List to store childWrapperCam objects.
        List<childWrapperCam> childList = new List<childWrapperCam>();
        System.debug('camRegistrList[0].Family_Attendances__r '+camRegistrList[0].Family_Attendances__r);
        // Loop through Family_Attendance__c records and create childWrapperCam objects.
        for(Family_Attendance__c famAtt : camRegistrList[0].Family_Attendances__r){
            System.debug(famAtt+ 'famAtt');
            childWrapperCam child = new childWrapperCam();
            child.regisId = famAtt.Id;
            child.regisName =  famAtt.Registration_Type__r.Name;
            child.famAtt = famAtt.FA_00000__c;
            // Check attendance status and check registration closed date less than today then display button or text in frontend
            if(famAtt.FA_00000__c == 'Accepted'){
                child.accept = true;
                //Registration date has passed
                if(camRegistrList[0].Registrations_Closed__c < System.today()){
                    child.regisAcceptText = true;
                }
                else{
                    child.regisAcceptText = false;
                }
            }
            else if(famAtt.FA_00000__c == 'Invited'){
                child.invited = true;
                if(camRegistrList[0].Registrations_Closed__c < System.today()){
                    child.showInvitedBtn = true;
                }
                else{
                    child.showInvitedBtn = false;
                }
            }
            else if(famAtt.FA_00000__c == 'Request to Attend'){
                child.requestToAttend = true;
                if(camRegistrList[0].Registrations_Closed__c < System.today()){
                    child.showrequestToAttend = true;
                }
                else{
                    child.showrequestToAttend = false;
                }
            }
            else if(famAtt.FA_00000__c == 'Declined'){
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
            if(!Test.isRunningTest()){
                if(famAtt.Family__c == con[0].AccountId ){
                    system.debug('child '+child);
                    childList.add(child);
                }
            }
        }
        // Set the childWrapper list in the WrapperRegisAtten object.
        wrap.childWrapper = childList;
        // Return the WrapperRegisAtten object.
        return wrap;
    }
    
    //This method updates the status and cancelation reason of a Family_Attendance__c. The updated record is then saved to the database.
    @AuraEnabled
    public Static void updateEventDetails(String famiAttId, String status, String cancelReason, String cancelResasonPicklist){
        // Query the Family_Attendance__c record based on the provided Id.
        List<Family_Attendance__c> famAtt = [Select Id, FA_00000__c, Cancellation_Reason__c,Declined_Reason__c ,(select Id ,Attendance__c from Family_Member_Attendance__r
        )from Family_Attendance__c WHERE ID =: famiAttId];
        List<Family_Member_Attendance__c> famMemAtt=famAtt[0].Family_Member_Attendance__r;
        List<Family_Member_Attendance__c> famMemAttList=new List<Family_Member_Attendance__c>();
        // Update the status based on the provided parameter.
        famAtt[0].FA_00000__c = status;

        if(!String.isBlank(cancelResasonPicklist)){
            famAtt[0].Declined_Reason__c = cancelResasonPicklist;
            System.debug('cancelResasonPicklist -->'+ cancelResasonPicklist);
        }
		System.debug('Status -->'+ status);
        // Check if the status is 'Cancelled' and update the cancellation reason.
        if(status == 'Cancelled'){
            famAtt[0].Cancellation_Reason__c = cancelReason;
            System.debug('cancelReason -->'+ cancelReason);
            if(famMemAtt.size() > 0){
                for(Family_Member_Attendance__c fma:famMemAtt){
                    if(fma.Attendance__c == 'Invited'){
                         fma.Attendance__c = 'Invited';
                         famMemAttList.add(fma);
                    }
                    else
                    {
                        fma.Attendance__c = status;
                         famMemAttList.add(fma);
                    }
                   
                }
            }
        }
        else if(status == 'Declined'){
            famAtt[0].FA_00000__c = status;
            if(famMemAtt.size() > 0){
                for(Family_Member_Attendance__c fma:famMemAtt){
                fma.Attendance__c = status;
                famMemAttList.add(fma);
            }
            }
            
            //famMemAtt[0].Attendance__c= status;
			System.debug('cancelReason -->'+ cancelReason);
        }
        else if(status == 'Invited'){
            famAtt[0].FA_00000__c = status;
        }
        else if(status == 'Request to Attend'){
            famAtt[0].FA_00000__c = status;
        }
        // Update the Family_Attendance__c record in the database.
        update famAtt; 
        update famMemAttList;
    }
    
    //Get the the data required in the table and then populates a wrapper object (WrapperFamilyData) with the necessary data and returns the serialized JSON of the wrapper object. 
    @AuraEnabled
    public static String getTableBtnData(String contId){
        
        //Query the specific contact record based on the paremeter.
        List<Contact> conList = [Select Id, Name, Shirt_Size__c, Swimming_Ability__c FROM Contact WHERE Id=:contId];
        //Retrive the special needs object records of the particular contact.
        List<Special_Needs__c> specialList = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c Where Contact__c =: conList[0].Id];
        // Initialize the wrapper object for table button data.
        WrapperFamilyData tableProfile = new WrapperFamilyData();
        // Populate the shirt size and swimming ability in the wrapper object.
        tableProfile.shirtSize = conList[0].Shirt_Size__c;
        tableProfile.swimmingAbility = conList[0].Swimming_Ability__c;
        // Check if there are special needs records.
        if(specialList.size() > 0 ){
            // Populate the wrapper object with special needs data
            List<DietWrapper> dietList = new List<DietWrapper>();
            List<SpeNeedWrapper> speList = new List<SpeNeedWrapper>();
            //Iterate special needs record and added in the list for the special needs and diet 
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
            // Check if there are dietary requirements and update the wrapper object.
            if(dietList.size() > 0 ){
                tableProfile.dietList = dietList;
                system.debug('Check table diet---->'+ tableProfile.dietList);
            }
            // Check if there are other special needs and update the wrapper object.
            if(speList.size() > 0 ){
                tableProfile.speNeedList = speList;
                system.debug('Check table Speial---->'+ tableProfile.speNeedList);
            }
        }
        // Return the serialized JSON representation of the wrapper object.
        return JSON.serialize(tableProfile);          
    }
    
    
    //This method returns data on click of confirm button 
    @AuraEnabled
    public static WrapperFamilyData getConfirmBtnData(String contId, String memId){
        List<User> usList = new List<User>();
        //Query the Contact record based on the provided Id.
        List<Contact> conList = [SELECT Id, AccountId, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Account.Preferred_Event_Locations__c, Account.Family_Interests__c,
                                 Account.media_opt_in_take_video_photos__c, Account.media_opt_in_share_participants__c, Account.Media_permission_Public_2019__c, Account.Media_permission_corporate_2019__c,
                                 Account.media_opt_in_share_participants_child__c, Account.Media_permission_Public_2019_Child__c, Account.Image_Opt_In_Permission_Corporate_Child__c, Account.Home_Phone__c,
                                 Account.Mobile_Phone__c, Swimming_Ability__c, Shirt_Size__c, Name, Family_Member_Type__c, Birthdate FROM CONTACT WHERE Id=:contId AND npsp__Deceased__c = false AND Exclude_From_Portal__c = false];
        // Query the Special_Needs__c records related to the Contact.
        List<Special_Needs__c> specialList = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c Where Contact__c =: conList[0].Id];
        // Query the Family_Member_Attendance__c record related to the Contact.
        List<Family_Member_Attendance__c> famMemberAtt = [Select Id, Special_Celebration__c,Transport_Pick_Up_Required__c,Transport_Drop_Off_Required__c,Child_Immunisation_Schedule_Current__c,
                                                          Last_Chemo_Dose_Date__c,OTC_Standard__c,OTC_Comments__c,Currently_on_Treatment__c,Medication_and_Vitamins__c,Requires_Doctors_Form__c,
                                                          Has_Portacath__c, Has_Central_Line__c, Event__r.Available_Getting_Home_Locations__c , Requires_Medication_or_Vitamins__c,
                                                          Event__r.Available_Getting_to_Camp_Locations__c, Transport_Pick_Up_Location__c, Transport_Drop_Off_Location__c FROM Family_Member_Attendance__c 
                                                          WHERE Id =: memId LIMIT 1 ];
        
        // Initialize the wrapper object for confirm button data.
        WrapperFamilyData confirmButtonData = new WrapperFamilyData();
        // Populate the wrapper object with basic information.
        confirmButtonData.shirtSize = conList[0].Shirt_size__c;  
        confirmButtonData.swimmingAbility = conList[0].Swimming_Ability__c;    
        if(famMemberAtt[0].Event__r.Available_Getting_Home_Locations__c == null &&  famMemberAtt[0].Event__r.Available_Getting_to_Camp_Locations__c == null){
            confirmButtonData.hideLocationField = true;
        }
        else{
            confirmButtonData.hideLocationField = false;
        }
        confirmButtonData.childImmunisationScheduleCurrent = famMemberAtt[0].Child_Immunisation_Schedule_Current__c;
        confirmButtonData.lastChemoDoseDate = String.valueOf(famMemberAtt[0].Last_Chemo_Dose_Date__c);
        confirmButtonData.OTCStandard = famMemberAtt[0].OTC_Standard__c;
       // confirmButtonData.OTCComments = famMemberAtt[0].OTC_Comments__c;
        confirmButtonData.currentlyonTreatment = famMemberAtt[0].Currently_on_Treatment__c;
		confirmButtonData.MedicationandVitamins = famMemberAtt[0].Medication_and_Vitamins__c;
		confirmButtonData.RequiresDoctorsForm = String.valueOf(famMemberAtt[0].Requires_Doctors_Form__c);
		confirmButtonData.hasCentralLine = famMemberAtt[0].Has_Central_Line__c;
		confirmButtonData.hasPortacath = famMemberAtt[0].Has_Portacath__c;
        confirmButtonData.specialCelebration = famMemberAtt[0].Special_Celebration__c;
        confirmButtonData.medicationAndVitaminsOptionsvalue = famMemberAtt[0].Medication_and_Vitamins__c;
        confirmButtonData.medicalComments = famMemberAtt[0].OTC_Comments__c;
        confirmButtonData.transportPickUpRequired = famMemberAtt[0].Transport_Pick_Up_Required__c;
        confirmButtonData.transportDropOffRequired = famMemberAtt[0].Transport_Drop_Off_Required__c;  
        confirmButtonData.eventtransportAccOrNot = famMemberAtt[0].Event__r.Available_Getting_Home_Locations__c;        
        confirmButtonData.homeTransportAcceptOrNot = famMemberAtt[0].Event__r.Available_Getting_to_Camp_Locations__c;
        confirmButtonData.memberId = famMemberAtt[0].Id; 
        confirmButtonData.requiresMedicationOrVitamins = famMemberAtt[0].Requires_Medication_or_Vitamins__c; 
        
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
            // Check if there are dietary requirements and update the wrapper object.
            if(dietList.size() > 0 ){
                confirmButtonData.dietList = dietList;
            }
            // Check if there are other special needs and update the wrapper object.
            if(speList.size() > 0 ){
                confirmButtonData.speNeedList = speList;
            }
        }
        // Return the populated wrapper object.
        return confirmButtonData;        
    }
    
    //The updatetableData method is responsible for updating the table data related to a contact based on the provided JSON data.
    @AuraEnabled
    public static void updatetableData(String jsonData , String contId){
        // Deserialize the JSON data into a WrapperFamilyData object.
        WrapperFamilyData familyDataList = (WrapperFamilyData) JSON.deserialize(jsonData, WrapperFamilyData.class);
        // Query the Contact record based on the provided Id.
        List<Contact> conList = [SELECT Id, AccountId, Email,Swimming_Ability__c, Shirt_Size__c, Name, Family_Member_Type__c, Birthdate 
                                 FROM CONTACT WHERE Id=:contId AND npsp__Deceased__c = false AND Exclude_From_Portal__c = false];
        // Query the Family_Member_Attendance__c record related to the Contact.
        List<Family_Member_Attendance__c> famMemberAtt = [SELECT Id, Special_Celebration__c,Transport_Pick_Up_Required__c,Medication_and_Vitamins__c,Transport_Pick_Up_Location__c, Transport_Drop_Off_Location__c,OTC_Comments__c,
                                                          Last_Chemo_Dose_Date__c,Has_Central_Line__c,Has_Portacath__c,OTC_Standard__c,Requires_Medication_or_Vitamins__c,Transport_Drop_Off_Required__c,Attendance__c  FROM Family_Member_Attendance__c 
                                                          WHERE Id =:familyDataList.memberId LIMIT 1];
        // Query the Special_Needs__c records related to the Contact.
        List<Special_Needs__c> specialList = [SELECT Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c FROM Special_Needs__c 
                                              WHERE Contact__c =: conList[0].Id];
        // Update the Contact record with swimming ability and shirt size comming from the wrapper class.
        conList[0].Swimming_Ability__c = familyDataList.swimmingAbility;
        conList[0].Shirt_Size__c = familyDataList.shirtSize;
        update conList[0];
        // Update the Family_Member_Attendance__c record with transportation and special celebration details comming from the wrapper class.
		famMemberAtt[0].Transport_Pick_Up_Required__c = familyDataList.transportDropOffRequired;
        famMemberAtt[0].Transport_Drop_Off_Required__c = familyDataList.transportPickUpRequired;
        famMemberAtt[0].Transport_Pick_Up_Location__c = familyDataList.eventtransportAccOrNot;
        famMemberAtt[0].Transport_Drop_Off_Location__c = familyDataList.homeTransportAcceptOrNot;      
        famMemberAtt[0].Special_Celebration__c = familyDataList.specialCelebration;
        famMemberAtt[0].Medication_and_Vitamins__c = familyDataList.medicationAndVitaminsOptionsvalue;
        famMemberAtt[0].OTC_Comments__c = familyDataList.medicalComments;
        famMemberAtt[0].Child_Immunisation_Schedule_Current__c=familyDataList.childImmunisationScheduleCurrent; 
        // famMemberAtt[0].Last_Chemo_Dose_Date__c= Date.valueof(familyDataList.lastChemoDoseDate); 
        famMemberAtt[0].OTC_Standard__c=familyDataList.OTCStandard; 
        //famMemberAtt[0].OTC_Comments__c=familyDataList.OTCComments; 
        famMemberAtt[0].Currently_on_Treatment__c=familyDataList.currentlyonTreatment ;
        //famMemberAtt[0].Medication_and_Vitamins__c=familyDataList.MedicationandVitamins; 
        famMemberAtt[0].Requires_Medication_or_Vitamins__c =familyDataList.requiresMedicationOrVitamins; 
        famMemberAtt[0].Has_Central_Line__c=familyDataList.hasCentralLine; 
        famMemberAtt[0].Has_Portacath__c=familyDataList.hasPortacath; 
        update famMemberAtt;
        
        // Initialize a list to store Special Needs records to upsert
        List<Special_Needs__c> speListToUpsert = new List<Special_Needs__c>();
        // Process and organize Diet and Special Needs data
        for(DietWrapper diet : familyDataList.dietList){
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
                    spe.Contact__c = contId;
                    spe.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Dietary_Requirement').getRecordTypeId();
                    spe.Long_Description__c = diet.dietDescription;
                    spe.Comments__c = diet.dietComment;
                    speListToUpsert.add(spe);
                }
            }
        }
        
        for(SpeNeedWrapper speObj : familyDataList.speNeedList){
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
                    spe.Contact__c = contId;
                    spe.RecordTypeId = Schema.SObjectType.Special_Needs__c.getRecordTypeInfosByDeveloperName().get('Special_Need').getRecordTypeId();
                    spe.Long_Description__c = speObj.specNeedDescription;
                    spe.Comments__c = speObj.specNeedComment;
                    speListToUpsert.add(spe);
                }
            }
        }
        
        // Upsert Special Needs records in the database.
        if(speListToUpsert.size() > 0){
            if(!Test.isRunningTest()){
                upsert speListToUpsert;
            }
            
        }
        
        // Process and delete Special Needs records if requested.
        Set<Id> deleteNeedIds = new Set<Id>();
        List<Special_Needs__c> speListForDelete = new List<Special_Needs__c>();
        
        if(familyDataList.speNeedDelete != null){
            for(SpeNeedDelete speDel : familyDataList.speNeedDelete){
                deleteNeedIds.add(speDel.id);
            }
            speListForDelete = [Select Id, Long_Description__c, RecordTypeId ,Comments__c, Contact__c From  Special_Needs__c where ID IN : deleteNeedIds ]; 
        }
        // Delete Special Needs records in the database.
        if(speListForDelete.size() > 0){
            delete speListForDelete;
        }
    }
    
	//Query family member attendence and returned it
    @AuraEnabled
    public static List<Family_Member_Attendance__c> getConDatafortable(String familyAttId){
        List<Family_Member_Attendance__c> familyAttendances = [SELECT Id, Contact__c, Contact__r.AccountId, Contact__r.Id, Contact__r.Name, 
                                                               Contact__r.Shirt_Size__c, Contact__r.Swimming_Ability__c, 
                                                               Contact__r.Family_Member_Type__c, Contact__r.Birthdate , Family_Attendance__c,
                                                               Family_Attendance__r.Event__c,Attendance__c 
                                                               FROM Family_Member_Attendance__c WHERE Family_Attendance__c =:familyAttId];
        
        return familyAttendances;  
    }
    
    //This method retrives the required data of a login user and stored in wrapper class variable and return the wrapper class. 
    @AuraEnabled
    public static GetAccountDataWrap getAccountDatatable(String recUserId , String campId, String famAttId){
        String decryptedString = FamilyPortalLoginController.decryptedData(recUserId);
        // Query the User records based on the current user's Id.
        List<User> usList = new List<User>();
        usList = [SELECT Id, ContactId FROM User WHERE Id = :decryptedString];
        User user = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        // Query the Contact records based on the ContactId from the User record.
        List<Contact> conList = [SELECT Id, AccountId, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Account.Preferred_Event_Locations__c, Account.Family_Interests__c,
                                 Account.media_opt_in_take_video_photos__c, Account.media_opt_in_share_participants__c, Account.Media_permission_Public_2019__c, Account.Media_permission_corporate_2019__c,
                                 Account.media_opt_in_share_participants_child__c, Account.Media_permission_Public_2019_Child__c, Account.Image_Opt_In_Permission_Corporate_Child__c, Account.Home_Phone__c,
                                 Account.Mobile_Phone__c, Swimming_Ability__c, Shirt_Size__c, Name, Family_Member_Type__c, Birthdate FROM CONTACT WHERE Id=:usList[0].ContactId AND npsp__Deceased__c = false AND Exclude_From_Portal__c = false];
        // Query the Account records based on the AccountId from the Contact record.
        LIST<Account> accList = [SELECT Id, Name, Emergency_Contact__c, Emergency_Contact_Mobile__c, Emergency_Contact_Phone__c, 
                                 Emergency_Contact_Relationship__c, media_opt_in_take_video_photos__c,media_opt_in_share_participants__c, 
                                 Media_Opt_in_Public_Sharing__c  FROM ACCOUNT WHERE Id=:conList[0].AccountId LIMIT 1]; 
        // Query the Family_Attendance__c records based on the AccountId from the Account record.
        List<Family_Attendance__c> fas = [SELECT Id, FA_00000__c, Agree_to_Participate_in_Event_Activities__c, Consent__c, Registration_Period__r.Id, Registration_Period__r.Name,
                                          Behavioral_Expectations__c ,Family_Member_On_Treatment__c, Family__c,Event__r.Id FROM Family_Attendance__c 
                                          WHERE Id=:famAttId];
		System.debug('---Fam Att-->'+ fas[0].Id);
        // Create an instance of the GetAccountDataWrap wrapper class.
        GetAccountDataWrap accWrap = new GetAccountDataWrap();
        // Populate the wrapper class with account and Family Attendance object data.
        if(fas.size() > 0 ){
            accWrap.consent = fas[0].Consent__c;
            accWrap.behavioralExpectations = fas[0].Behavioral_Expectations__c;
            accWrap.regisPeriodName = fas[0].Registration_Period__r.Id;
            accWrap.family_Member_On_Treatment = fas[0].Family_Member_On_Treatment__c;
        }
        accWrap.emergency_Contact = accList[0].Emergency_Contact__c;
        accWrap.emergency_Contact_Phone = accList[0].Emergency_Contact_Phone__c;
        accWrap.emergency_Contact_Mobile = accList[0].Emergency_Contact_Mobile__c;
        accWrap.emergency_Contact_Relationship = accList[0].Emergency_Contact_Relationship__c;
        accWrap.mediaTakePhoto = accList[0].media_opt_in_take_video_photos__c;
        accWrap.mediaparticipant = accList[0].media_opt_in_share_participants__c;
        accWrap.mediaSharingPhoto = accList[0].Media_Opt_in_Public_Sharing__c;
        // Return the populated wrapper class.
        return accWrap;       
    }
    //This method updates account-related data based on the provided GetAccountDataWrap wrapper object.
    @AuraEnabled
    public static String updateAccountData(GetAccountDataWrap accData, String recUserId , String campId , String femAttId, List<String> famMemList){
        String decryptedString = FamilyPortalLoginController.decryptedData(recUserId);
        // Query the User records based on the current user's Id.
        List<User> usList = new List<User>();
        usList = [SELECT Id, ContactId FROM User WHERE Id = :decryptedString];
        // Query the Contact records based on the ContactId from the User record.
        List<Contact> conList = [SELECT Id, AccountId, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Account.Preferred_Event_Locations__c, Account.Family_Interests__c,
                                 Account.media_opt_in_take_video_photos__c, Account.media_opt_in_share_participants__c, Account.Media_permission_Public_2019__c, Account.Media_permission_corporate_2019__c,
                                 Account.media_opt_in_share_participants_child__c, Account.Media_permission_Public_2019_Child__c, Account.Image_Opt_In_Permission_Corporate_Child__c, Account.Home_Phone__c,
                                 Account.Mobile_Phone__c, Swimming_Ability__c, Shirt_Size__c, Name, Family_Member_Type__c, Birthdate FROM CONTACT WHERE Id=:usList[0].ContactId AND npsp__Deceased__c = false AND Exclude_From_Portal__c = false];
        // Query the Account records based on the AccountId from the Contact record.
        LIST<ACCOUNT> accList = [SELECT Id, Name,Emergency_Contact__c, Emergency_Contact_Mobile__c, Emergency_Contact_Phone__c, 
                                 Emergency_Contact_Relationship__c, media_opt_in_take_video_photos__c,media_opt_in_share_participants__c, 
                                 Media_Opt_in_Public_Sharing__c  FROM ACCOUNT WHERE Id=:conList[0].AccountId LIMIT 1]; 
        // Query the Family_Attendance__c records based on the AccountId from the Account record.
        List<Family_Attendance__c> fas = [SELECT Id, FA_00000__c, Agree_to_Participate_in_Event_Activities__c, Consent__c, Registration_Period__r.Id, Registration_Period__r.Name,
                                          Behavioral_Expectations__c ,Family_Member_On_Treatment__c, Family__c,Event__r.Id FROM Family_Attendance__c  
                                          WHERE Id =: femAttId];
        List<Family_Member_Attendance__c> famUpdateList = new List<Family_Member_Attendance__c>();
		if(famMemList.size() > 0){
            List<Family_Member_Attendance__c> familyAttendances = [SELECT Id, Attendance__c FROM Family_Member_Attendance__c WHERE Id IN:famMemList];
            for(Family_Member_Attendance__c femAtt : familyAttendances){
                femAtt.Attendance__c = 'Request to Attend';
                    famUpdateList.add(femAtt);
                }
            }
            if(famUpdateList.size() > 0 ){
                update famUpdateList;
            }
        // Update the Account and Family attendence records with the provided data.
        accList[0].Emergency_Contact__c = accData.emergency_Contact;
        accList[0].Emergency_Contact_Mobile__c = accData.emergency_Contact_Mobile;
        accList[0].Emergency_Contact_Phone__c = accData.emergency_Contact_Phone;
        accList[0].Emergency_Contact_Relationship__c = accData.emergency_Contact_Relationship;
        accList[0].media_opt_in_take_video_photos__c = accData.mediaTakePhoto;
        accList[0].media_opt_in_share_participants__c = accData.mediaparticipant;
        accList[0].Media_Opt_in_Public_Sharing__c = accData.mediaSharingPhoto;
        //Update account and family attendence.
        Update accList[0];
        if(fas.size() > 0){
            fas[0].Registration_Period__c = accData.regisPeriodName;
			System.debug('--fas[0].Registration_Period__c---'+ fas[0].Registration_Period__c);
            fas[0].Consent__c = accData.consent;
            fas[0].Behavioral_Expectations__c = accData.behavioralExpectations;
            fas[0].Family_Member_On_Treatment__c = accData.family_Member_On_Treatment;
            fas[0].FA_00000__c = 'Request to Attend';
            Update fas[0];
        }
        // Return a success message.
        return 'Sucessfully';
    }
            
    //Display picklist value of preferres session 
    @AuraEnabled
    public static List<SelectOptionWrapper> preferredSessionPicklist(String camId) {
        
        
        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
        // Query for Account names
        List<Registration_Type_Period__c> rtfList = [SELECT ID , Name ,Registration_Period__c,Registration_Type__c,
                                                     Registration_Period__r.Name, Registration_Period__r.Id,
                                                     Registration_Type__r.RecordType.Name FROM Registration_Type_Period__c 
                                                     WHERE Registration_Period__r.Campaign__c =: camId];
        
        // Query to get VolunteerAttendance__c records for the specific campaign
        List<Family_Attendance__c> famAttendances = [SELECT Id, Registration_Type__c FROM Family_Attendance__c 
                                                              WHERE Event__c =: camId];
		        // Create a set of Registration_Type__c IDs from the famAttendances
        Set<Id> famRegistrationTypeIds = new Set<Id>();
		for (Family_Attendance__c fma : famAttendances) {
            famRegistrationTypeIds.add(fma.Registration_Type__c);
        }

		
        
        for(Registration_Type_Period__c rtf : rtfList ){
            if (famRegistrationTypeIds.contains(rtf.Registration_Type__c)) {          
                options.add(new SelectOptionWrapper(rtf.Registration_Period__r.Name,rtf.Registration_Period__r.Id));
            }
            }
        return options;
        
    }
    
    
    //Display picklist value of transport session 
    @AuraEnabled
    public static List<String> transportLocationHome(String camId) {
        
        
        //List<Volunteer_Attendance__c> regVolAtt = [SELECT Id, Registration_Period__c from Volunteer_Attendance__c WHERE Id=:volAttenId];
        List<SelectTranportOptionWrapper> options = new List<SelectTranportOptionWrapper>();
        // Query for Account names
        List<Campaign> camList = [SELECT Id, Available_Getting_Home_Locations__c, Available_Getting_to_Camp_Locations__c FROM Campaign WHERE Id=:camId];
        
        
        List<SelectTranportOptionWrapper> optionsHome = new List<SelectTranportOptionWrapper>();
        List<String> pickLocList = new List<String>();
        if(String.isnotBlank(camList[0].Available_Getting_Home_Locations__c)){
            if(camList[0].Available_Getting_Home_Locations__c.contains(';')){
                pickLocList = camList[0].Available_Getting_Home_Locations__c.split(';');
            }
            else{
                pickLocList.add(camList[0].Available_Getting_Home_Locations__c);
            }
            
            
        }
        return pickLocList;
    }
    
    @AuraEnabled
    public static List<String> transportLocationPic(String camId) {
    // Query for Account names
        List<Campaign> camList = [SELECT Id, Available_Getting_Home_Locations__c,RecordType.DeveloperName, Available_Getting_to_Camp_Locations__c FROM Campaign WHERE Id=:camId];
       
        List<SelectTranportPickUpOptionWrapper> optionsHome = new List<SelectTranportPickUpOptionWrapper>();
        // Populate the picklist options with Account names
        List<String> pickLocList = new List<String>();
        if(String.isnotBlank(camList[0].Available_Getting_to_Camp_Locations__c)){
            if(camList[0].Available_Getting_to_Camp_Locations__c.contains(';')){
                pickLocList = camList[0].Available_Getting_to_Camp_Locations__c.split(';');
            }
            else{
                pickLocList.add(camList[0].Available_Getting_to_Camp_Locations__c);
            }
        }
        
        return pickLocList;
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
    
    //The GetAccountDataWrap class defines the wrapper class for account-related data used in Lightning components.
    public class GetAccountDataWrap{
        @AuraEnabled public String emergency_Contact {get;set;}
        @AuraEnabled public String emergency_Contact_Phone {get;set;}
        @AuraEnabled public String emergency_Contact_Mobile {get;set;}
        @AuraEnabled public String emergency_Contact_Relationship {get;set;}
        @AuraEnabled public Boolean family_Member_On_Treatment {get;set;}
        @AuraEnabled public Boolean mediaTakePhoto {get;set;}
        @AuraEnabled public Boolean mediaparticipant {get;set;}
        @AuraEnabled public Boolean mediaSharingPhoto {get;set;}
        @AuraEnabled public Boolean consent {get;set;}
        @AuraEnabled public Boolean behavioralExpectations {get;set;}
        @AuraEnabled public String regisPeriodName {get;set;}
        
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
    
    public class SelectTranportOptionWrapper {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        
        // Constructor for String values
        public SelectTranportOptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }        
    }
    
    public class SelectTranportPickUpOptionWrapper {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        
        // Constructor for String values
        public SelectTranportPickUpOptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }        
    }
    
    //The WrapperRegisAtten class defines the wrapper class for event registration and attendance information i.e campaign related data.
    public class WrapperRegisAtten{        
        @AuraEnabled public String eventType {get;set;}
        @AuraEnabled public String startDate  {get;set;}
        @AuraEnabled public String eventTime {get;set;}
        @AuraEnabled public String endDate {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String RSVP {get;set;}
        @AuraEnabled public String Venue_Address {get;set;}
        @AuraEnabled public String portalTitle {get;set;}
        @AuraEnabled public String accName {get;set;}
        @AuraEnabled public String addStreet {get;set;}
        @AuraEnabled public String addCity {get;set;}
        @AuraEnabled public String addState {get;set;}
        @AuraEnabled public String addPostalCode {get;set;}
        @AuraEnabled public String addCountry {get;set;}  
        @AuraEnabled public String portalDescription {get;set;}
        @AuraEnabled public List<FetchEventDataImages> blobEventImages {get;set;}
        @AuraEnabled public List<childWrapperCam> childWrapper {get;set;} 
        @AuraEnabled public String recordTypeName {get;set;}  
    }
    //The childWrapperCam class defines the wrapper class for family attendee data information.
    public class childWrapperCam{        
        @AuraEnabled public String regisId {get;set;}
        @AuraEnabled public String regisName {get;set;}
        @AuraEnabled public String famAtt {get;set;}
        @AuraEnabled public Boolean accept {get;set;}
        @AuraEnabled public Boolean invited {get;set;}
        @AuraEnabled public Boolean requestToAttend {get;set;}
        @AuraEnabled public Boolean declined {get;set;}
        @AuraEnabled public Boolean showInvitedBtn {get;set;}
        @AuraEnabled public Boolean showDeclinedBtn {get;set;}
        @AuraEnabled public Boolean showrequestToAttend {get;set;}
        @AuraEnabled public Boolean regisAcceptText {get;set;}        
    } 
    
    //The WrapperFamilyData class defines the wrapper class for contact data.
    public class WrapperFamilyData{        
        @AuraEnabled public String shirtSize {get;set;}
        @AuraEnabled public String swimmingAbility {get;set;}
        @AuraEnabled public List<dietWrapper> dietList {get;set;}
        @AuraEnabled public List<SpeNeedWrapper> speNeedList {get;set;}       
        @AuraEnabled public List<SpeNeedDelete> speNeedDelete {get;set;}
        @AuraEnabled public String specialCelebration{get;set;}
        @AuraEnabled public String medicationAndVitaminsOptionsvalue{get;set;}
        @AuraEnabled public String medicalComments{get;set;}
        @AuraEnabled public String transportPickUpRequired{get;set;}
        @AuraEnabled public String transportDropOffRequired{get;set;}
        @AuraEnabled public String eventtransportAccOrNot{get;set;}
        @AuraEnabled public String homeTransportAcceptOrNot{get;set;} 
        @AuraEnabled public Boolean hideLocationField{get;set;} 
        @AuraEnabled public String memberId{get;set;}        
        @AuraEnabled public String lastChemoDoseDate{get;set;}
        @AuraEnabled public String OTCStandard{get;set;}
        @AuraEnabled public String OTCComments{get;set;}
        @AuraEnabled public String currentlyonTreatment{get;set;}
        @AuraEnabled public String MedicationandVitamins{get;set;}
        @AuraEnabled public String RequiresDoctorsForm{get;set;}
        @AuraEnabled public String hasCentralLine{get;set;}
        @AuraEnabled public String hasPortacath{get;set;}
        @AuraEnabled public String childImmunisationScheduleCurrent{get;set;}
        @AuraEnabled public String requiresMedicationOrVitamins{get;set;}
        @AuraEnabled public String checkBoxmedicationAndVitamins{get;set;}
    }
    //The DietWrapper class defines the wrapper class for dietary requirement information.
    public class DietWrapper{
        @AuraEnabled public String dietDescription {get;set;}
        @AuraEnabled public String dietComment {get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String recordId {get;set;}
    }
    //The SpeNeedWrapper class defines the wrapper class for special needs requirements information.
    public class SpeNeedWrapper{
        @AuraEnabled public String specNeedDescription {get;set;}
        @AuraEnabled public String specNeedComment {get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String recordId {get;set;}
    }
    //The SpeNeedDelete class defines the wrapper class for special needs deletion.
    public class SpeNeedDelete{
        @AuraEnabled public String id {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getFamAttPicklistValues() {
        List<Schema.PicklistEntry> entries = Family_Attendance__c.Declined_Reason__c.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
            values.add(valueMap);
        }
        return values;
    }

}