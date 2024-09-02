public with sharing class portalEditVolunteerProfileController {
	public Contact userContact{get;set;}
    public Account family{get;set;}
    public Account userAccount{get;set;}
    public Map<Id,Contact> familyContactMap{get;set;}

    public Boolean isEditing{get;set;}

    public Map<String, Special_Needs__c> currentNeeds{get;set;}
    public Integer countNeeds{get;set;}

    public String successMsg{get;set;}
    public String errorMsg{get;set;}

    public Map<String, Id> specialNeedRTs{get;set;}

    public Boolean hasSuccess{get{ return String.isNotEmpty(successMsg); }set;}
    public Boolean hasError{get{ return ApexPages.hasMessages() || String.isNotEmpty(errorMsg); }set;}

    public Volunteer_Skill__c wwc{get;set;}
    public Map<String, Volunteer_Type__c> vTypes{get;set;}
    public Volunteer_Type__c newVType{get;set;}

    public Attachment__c profileImage {
        get {
            List<Attachment__c> attaches = [SELECT Id, AttachmentID__c, Content_Type__c FROM Attachment__c WHERE Attachment_Type__c = 'Profile Image' AND Contact__c = :userContact.Id AND (Show_in_Portal__c = 'Volunteer' OR Show_in_Portal__c = 'Both')];

            if(!attaches.isEmpty()) {
                profileImage = attaches[0];
            }

            return profileImage;
        }
        set;
    }

    public portalEditVolunteerProfileController() {

        userContact = portalCore.userContact;

        family = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Home_Phone__c, Mobile_Phone__c, Email__c, Media_Permission_Denied__c,
                Media_Permission_Functions__c, Media_Permission_Interviews__c, Media_Permission_Photos__c, Media_Permission_Photo_Share__c, Media_Permission_Pub__c, media_opt_in_take_video_photos__c, media_opt_in_share_participants__c, Media_Opt_in_Public_Sharing__c, Preferred_Event_Locations__c, Family_Interests__c,
                npe01__One2OneContact__r.Requests_No_Newsletter__c, npe01__One2OneContact__r.Requests_no_Marketing_Materials__c,
                Media_Permission_All_2019__c, Media_permission_Public_2019__c, Media_permission_corporate_2019__c,
        (SELECT Id, FirstName, LastName, Family_Member_Type__c, Birthdate, Swimming_Ability__c, Shirt_Size__c FROM Contacts WHERE npsp__Deceased__c = false AND Exclude_From_Portal__c = false)
        FROM Account WHERE Id = :userContact.AccountId];
        currentNeeds = new Map<String, Special_Needs__c>();
        countNeeds = 0;
        Boolean hasDiet = false;
        Boolean hasNeeds = false;

        specialNeedRTs = new Map<String, Id>();

        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Special_Needs__c' AND (DeveloperName = 'Dietary_Requirement' OR DeveloperName = 'Special_Need')]) {
            if(rt.DeveloperName == 'Dietary_Requirement') {
                specialNeedRTs.put('DietryNeeds', rt.Id);
            } else if(rt.DeveloperName == 'Special_Need') {
                specialNeedRTs.put('SpecialNeeds', rt.Id);
            }
        }

        for(Special_Needs__c sn : [SELECT Id, AttributeType__c, Comments__c, Contact__c, Date__c, Long_Description__c FROM Special_Needs__c WHERE Contact__c = :userContact.Id]) {
            if(sn.AttributeType__c == 'DietryNeeds') {
                hasDiet = true;
            } else if(sn.AttributeType__c == 'SpecialNeeds') {
                hasNeeds = true;
            }

            currentNeeds.put(sn.Id, sn);
        }

        if(!hasDiet) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = userContact.Id, Date__c = Date.today());

            if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
                sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }

        if(!hasNeeds) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'SpecialNeeds', Contact__c = userContact.Id, Date__c = Date.today());

            if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
                sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }

        List<RecordType> wwcRTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Volunteer_Skill__c' AND DeveloperName = 'Working_With_Children_Check'];

        if(!wwcRTypes.isEmpty()) {
        	List<Volunteer_Skill__c> wwcs = [SELECT Id, Skill_Description__c, License__c, License_No__c, Expires__c FROM Volunteer_Skill__c WHERE Volunteer__c = :userContact.Id AND RecordTypeId = :wwcRTypes[0].Id ORDER BY Expires__c DESC ];

        	if(!wwcs.isEmpty()) {
        		wwc = wwcs[0];
        	} else {
        		wwc = new Volunteer_Skill__c(Volunteer__c = userContact.Id, RecordTypeId = wwcRTypes[0].Id);
        	}
        }

        vTypes = new Map<String, Volunteer_Type__c>([SELECT Id, Volunteer__c, Volunteer_Type__C, Volunteer_Status__c, Start_Date__c, End_Date__c FROM Volunteer_Type__c WHERE Volunteer__c = :userContact.Id AND Volunteer_Status__c != 'Inactive']);
        newVType = new Volunteer_Type__c(Volunteer__c = userContact.Id, Volunteer_Status__c = 'Interested');

    }

    public void editContact() {
        successMsg = '';
        errorMsg = '';
        isEditing = true;
    }


    public void cancelContact() {
        successMsg = '';
        errorMsg = '';
        isEditing = false;
    }

    public void saveContact() {

    	successMsg = '';
        errorMsg = '';
        isEditing = false;

        try {

            update userContact;
            update family;

        } catch(DmlException ex) {

            System.debug(ex);
            ApexPages.addMessages(ex);
            return;

        }

        List<Special_Needs__c> updateNeeds = new List<Special_Needs__c>();

        for(Special_Needs__c sn : currentNeeds.values()) {
            if(String.isNotEmpty(sn.Long_Description__c)) {
                updateNeeds.add(sn);
            }
        }

        if(updateNeeds.size() > 0) {
            try {

                upsert updateNeeds;

            } catch(DmlException ex) {

                System.debug(ex);
                ApexPages.addMessages(ex);
                return;

            }
        }

        if(String.isNotEmpty(wwc.Skill_Description__c) || String.isNotEmpty(wwc.License_No__c) || wwc.Expires__c != null) {
        	try {

                upsert wwc;

            } catch(DmlException ex) {

                System.debug(ex);
                ApexPages.addMessages(ex);
                return;

            }
        }

        successMsg = 'Volunteer updated successfully.';

    }

    public String removeVTypeId{get;set;}

    public void addVolunteerType() {

    	if(String.isNotEmpty(newVType.Volunteer_Type__c)) {
			try {

                insert newVType;

            } catch(DmlException ex) {

                System.debug(ex);
                ApexPages.addMessages(ex);
                return;

            }

            vTypes.put(newVType.Id, newVType);
            newVType = new Volunteer_Type__c(Volunteer__c = userContact.Id, Volunteer_Status__c = 'Interested');

            successMsg = 'Volunteer Type request successful.';
    	}

    	errorMsg = 'Please set the Volunteer Type that you would like to request.';

    }

    public void removeVolunteerType() {

    	if(String.isNotEmpty(removeVTypeId) && removeVTypeId InstanceOf ID) {

    		Volunteer_Type__c vType = vTypes.remove(removeVTypeId);

    		if(vType != null) {

    			vType.End_Date__c = Date.today();
    			vType.Volunteer_Status__c = 'Inactive';

                try {

                    update vType;

                } catch(DmlException ex) {

                    System.debug(ex);
                    ApexPages.addMessages(ex);
                    return;

                }

                successMsg = 'Volunteer Type has been removed.';

            }

    	}

    	errorMsg = 'Volunteer Type not found.';
    }

    public String addType{get;set;}

    public void addSpecialNeed() {

        if(currentNeeds != null && String.isNotEmpty(addType)) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = addType, Contact__c = userContact.Id, Date__c = Date.today());

            if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
                sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }
    }

    public String removeNeedId{get;set;}

    public void removeSpecialNeed() {
        if(currentNeeds.containsKey(removeNeedId)) {
            Special_Needs__c rNeed = currentNeeds.remove(removeNeedId);

            if(removeNeedId InstanceOf ID) {

                try {

                    delete rNeed;

                } catch(DmlException ex) {

                    System.debug(ex);
                    ApexPages.addMessages(ex);
                    return;

                }

            }

        }
    }

    public void changeAllMediaOpt() {
        userContact.media_opt_in_share_participants__c = userContact.Media_Permission_All_2019__c;
        userContact.Media_permission_Public_2019__c = userContact.Media_Permission_All_2019__c;
        userContact.Media_permission_corporate_2019__c = userContact.Media_Permission_All_2019__c;
    }

}