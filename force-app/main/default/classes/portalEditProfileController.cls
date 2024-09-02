public class portalEditProfileController {

    public Contact userContact { get; set; }
    public Account family { get; set; }
    public Account familyCopy {get; set;}
    public Map<Id, Contact> familyContactMap { get; set; }

    public Boolean isEditing { get; set; }

    public String successMsg { get; set; }
    public String errorMsg { get; set; }

    public Map<String, Id> specialNeedRTs { get; set; }

    public Boolean hasSuccess { get {return String.isNotEmpty(successMsg);} set; }
    public Boolean hasError { get {return ApexPages.hasMessages() || String.isNotEmpty(errorMsg);} set; }

    public portalEditProfileController() {

        userContact = portalCore.userContact;

        family = [
                SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Home_Phone__c, Mobile_Phone__c, Email__c, Media_Permission_Denied__c,
                        Media_Permission_Functions__c, Media_Permission_Interviews__c, Media_Permission_Photos__c, Media_Permission_Photo_Share__c, Media_Permission_Pub__c, media_opt_in_take_video_photos__c, media_opt_in_share_participants__c, Media_Opt_in_Public_Sharing__c, Preferred_Event_Locations__c, Family_Interests__c,
                        npe01__One2OneContact__r.Requests_No_Newsletter__c, npe01__One2OneContact__r.Requests_no_Marketing_Materials__c,Image_Opt_In_Permission_Corporate_Child__c,
                        Media_Permission_All_2019__c, Media_permission_Public_2019__c, Media_permission_corporate_2019__c,media_opt_in_share_participants_child__c,Media_permission_Public_2019_Child__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c, Birthdate, Swimming_Ability__c, Shirt_Size__c FROM Contacts WHERE npsp__Deceased__c = false AND Exclude_From_Portal__c = false)
                FROM Account
                WHERE Id = :userContact.AccountId
        ];

        familyContactMap = new Map<Id, Contact>();

        for (Contact fc : family.Contacts) {
            familyContactMap.put(fc.Id, fc);
        }

        specialNeedRTs = new Map<String, Id>();

        for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Special_Needs__c' AND (DeveloperName = 'Dietary_Requirement' OR DeveloperName = 'Special_Need')]) {
            if (rt.DeveloperName == 'Dietary_Requirement') {
                specialNeedRTs.put('DietryNeeds', rt.Id);
            } else if (rt.DeveloperName == 'Special_Need') {
                specialNeedRTs.put('SpecialNeeds', rt.Id);
            }
        }

    }

    public void editFamily() {
        successMsg = '';
        errorMsg = '';
        isEditing = true;
    }

    public void saveFamily() {
        successMsg = '';
        errorMsg = '';
        isEditing = false;


        try {

            if (!family.media_opt_in_take_video_photos__c) {
                family.media_opt_in_share_participants__c = false;
                family.Media_permission_Public_2019__c = false;
                family.Media_permission_corporate_2019__c = false;
                family.media_opt_in_share_participants_child__c = false;
                family.Media_permission_Public_2019_Child__c = false;
                family.Image_Opt_In_Permission_Corporate_Child__c = false;
            }
            update family;


            if (String.isNotBlank(family.npe01__One2OneContact__c))
                update family.npe01__One2OneContact__r;

        } catch (DmlException ex) {

            System.debug(ex);
            ApexPages.addMessages(ex);
            return;

        }

        successMsg = 'Family details updated.';


    }

    public void cancelFamily() {
        Account acc = [
                SELECT media_opt_in_take_video_photos__c,
                        media_opt_in_share_participants__c,
                        Media_permission_Public_2019__c,
                        Media_permission_corporate_2019__c,
                        media_opt_in_share_participants_child__c,
                        Media_permission_Public_2019_Child__c,
                        Image_Opt_In_Permission_Corporate_Child__c
                FROM Account
                WHERE Id = :userContact.AccountId
        ];
        if(family.media_opt_in_take_video_photos__c != acc.media_opt_in_take_video_photos__c){
            family.media_opt_in_take_video_photos__c = !family.media_opt_in_take_video_photos__c;
        }
        family.media_opt_in_share_participants__c = acc.media_opt_in_share_participants__c;
        family.Media_permission_Public_2019__c = acc.Media_permission_Public_2019__c;
        family.Media_permission_corporate_2019__c = acc.Media_permission_corporate_2019__c;
        family.media_opt_in_share_participants_child__c = acc.media_opt_in_share_participants_child__c;
        family.Media_permission_Public_2019_Child__c = acc.Media_permission_Public_2019_Child__c;
        family.Image_Opt_In_Permission_Corporate_Child__c = acc.Image_Opt_In_Permission_Corporate_Child__c;
        successMsg = '';
        errorMsg = '';
        isEditing = false;

    }
    public void onchangeOfOptIn() {
        if(userContact.AccountId !=null){
            familyCopy = [
                    SELECT media_opt_in_share_participants__c,
                            Media_permission_Public_2019__c,
                            Media_permission_corporate_2019__c,
                            media_opt_in_share_participants_child__c,
                            Media_permission_Public_2019_Child__c,
                            Image_Opt_In_Permission_Corporate_Child__c
                            FROM Account
                    WHERE Id = :userContact.AccountId
            ];
            family.media_opt_in_share_participants__c = familyCopy.media_opt_in_share_participants__c;
            family.Media_permission_Public_2019__c = familyCopy.Media_permission_Public_2019__c;
            family.Media_permission_corporate_2019__c = familyCopy.Media_permission_corporate_2019__c;
            family.media_opt_in_share_participants_child__c = familyCopy.media_opt_in_share_participants_child__c;
            family.Media_permission_Public_2019_Child__c = familyCopy.Media_permission_Public_2019_Child__c;
            family.Image_Opt_In_Permission_Corporate_Child__c = familyCopy.Image_Opt_In_Permission_Corporate_Child__c;
        }else {
            errorMsg = '';
            errorMsg = 'Could not find the User Contact Id';
        }


    }


    public Id editContactId { get; set; }
    public Contact currentContact { get; set; }
    public Map<String, Special_Needs__c> currentNeeds { get; set; }
    public Integer countNeeds { get; set; }

    public void editContact() {
        successMsg = '';
        errorMsg = '';

        if (String.isNotEmpty(editContactId) && familyContactMap.containsKey(editContactId)) {
            currentContact = familyContactMap.get(editContactId);
        }

        currentNeeds = new Map<String, Special_Needs__c>();
        countNeeds = 0;
        Boolean hasDiet = false;
        Boolean hasNeeds = false;

        for (Special_Needs__c sn : [SELECT Id, AttributeType__c, Comments__c, Contact__c, Date__c, Long_Description__c FROM Special_Needs__c WHERE Contact__c = :editContactId]) {
            if (sn.AttributeType__c == 'DietryNeeds') {
                hasDiet = true;
            } else if (sn.AttributeType__c == 'SpecialNeeds') {
                hasNeeds = true;
            }

            currentNeeds.put(sn.Id, sn);
        }

        if (!hasDiet) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = editContactId, Date__c = Date.today());

            if (specialNeedRTs.containsKey(sNeed.AttributeType__c))
                sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }

        if (!hasNeeds) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'SpecialNeeds', Contact__c = editContactId, Date__c = Date.today());

            if (specialNeedRTs.containsKey(sNeed.AttributeType__c))
                sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }

        System.debug('currentNeeds: ' + currentNeeds);

    }

    public void saveContact() {

        try {

            update currentContact;

        } catch (DmlException ex) {

            System.debug(ex);
            ApexPages.addMessages(ex);
            return;

        }

        List<Special_Needs__c> updateNeeds = new List<Special_Needs__c>();

        for (Special_Needs__c sn : currentNeeds.values()) {
            if (String.isNotEmpty(sn.Long_Description__c)) {
                updateNeeds.add(sn);
            }
        }

        if (updateNeeds.size() > 0) {
            try {

                upsert updateNeeds;

            } catch (DmlException ex) {

                System.debug(ex);
                ApexPages.addMessages(ex);
                return;

            }
        }

        currentContact = null;
        currentNeeds = null;

        successMsg = 'Family member updated successfully.';

    }

    public void cancelContact() {

        currentContact = null;
        currentNeeds = null;

    }

    public String addType { get; set; }

    public void addSpecialNeed() {
        if (currentNeeds != null && String.isNotEmpty(addType)) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = addType, Contact__c = editContactId, Date__c = Date.today());

            if (specialNeedRTs.containsKey(sNeed.AttributeType__c))
                sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }
    }

    public String removeNeedId { get; set; }

    public void removeSpecialNeed() {
        if (currentNeeds.containsKey(removeNeedId)) {
            Special_Needs__c rNeed = currentNeeds.remove(removeNeedId);

            if (removeNeedId InstanceOf ID) {

                try {

                    delete rNeed;

                } catch (DmlException ex) {

                    System.debug(ex);
                    ApexPages.addMessages(ex);
                    return;

                }

            }

        }
    }

    public void changeAllMediaOpt() {
        family.media_opt_in_share_participants__c = family.Media_Permission_All_2019__c;
        family.Media_permission_Public_2019__c = family.Media_Permission_All_2019__c;
        family.Media_permission_corporate_2019__c = family.Media_Permission_All_2019__c;
    }
}