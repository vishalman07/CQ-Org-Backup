public class portalEventController {
    
    
    public String eventId {get;set;}
    public Boolean eventOff {get;set;}
    public Boolean isRegistering {get;set;}
    
    public Account family{get;set;}
    public Map<Id,Contact> familyContactMap{get;set;}
    public Map<Id, Boolean> familyAttendingMap{get;set;}
    
    //public Boolean agreeToParticipate{get;set;}
    public Boolean givenConsent{get;set;}
    public Boolean familyOnTreatment{get;set;}
    public Boolean behavioralExpectations{get;set;}
    
    public String eventType{get;set;}
    
    public Contact member {get;set;}
    public Account venue {get;set;}
    
    public String successMsg{get;set;}
    public String errorMsg{get;set;}

    public Map<String, Id> specialNeedRTs{get;set;}
    
    public Boolean hasSuccess{get{ return String.isNotEmpty(successMsg); }set;}
    public Boolean hasError{get{ return ApexPages.hasMessages() || String.isNotEmpty(errorMsg); }set;}    

    public List<Attachment__c> attachments{get;set;}
    
    public Boolean cancellationAvailable{get{ return event != null && event.containsKey('Registrations_Cancellation__c') && (Datetime)event.get('Registrations_Cancellation__c').Value > Datetime.now(); }set;}
    public Boolean registrationAvailable{
        get{
            return event != null && 
                event.containsKey('Registrations_Remaining__c') && 
                (Decimal)event.get('Registrations_Remaining__c').Value > 0 && 
                event.containsKey('Registrations_Open__c') && 
                event.containsKey('Registrations_Closed__c') && 
                (Datetime)event.get('Registrations_Open__c').Value < Datetime.now() && 
                (Datetime)event.get('Registrations_Closed__c').Value > Datetime.now();
        }
        set;
    }
    
    public portalEventController() {
        
        member = portalCore.userContact;
        
        eventId = ApexPages.currentPage().getParameters().get('e');
        
        loadEvent(eventId);
        loadBooking(eventId);
        loadingRegTypes(eventId);

        specialNeedRTs = new Map<String, Id>();

        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Special_Needs__c' AND (DeveloperName = 'Dietary_Requirement' OR DeveloperName = 'Special_Need')]) {
            if(rt.DeveloperName == 'Dietary_Requirement') {
                specialNeedRTs.put('DietryNeeds', rt.Id);
            } else if(rt.DeveloperName == 'Special_Need') {
                specialNeedRTs.put('SpecialNeeds', rt.Id);
            }
        }
        
    }
    
    public Map<String, Field> event {get;set;}
    public Map<String, Map<String,Field>> bookings {get;set;}
    public Map<String, Map<String,Field>> regTypes {get;set;}
    
    public void loadEvent(String eId) {
        
        event = new Map<String, Field>();
        
        Schema.DescribeSObjectResult objDescribe = Campaign.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        String theQuery = 'SELECT ';
        
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        
        theQuery += ' FROM Campaign WHERE Id = :eId';
        
        System.Debug('theQuery: ' + theQuery);
        
        try {
            
            List<Campaign> objList = Database.query(theQuery);
            
            System.debug('orderList: ' + objList);
            
            for(Campaign c : objList) {
                
                if(c.Status != 'Open')
                    eventOff = true;
                
                for(Schema.SObjectField s : fieldMap.values()) {
                    
                    event.put((String)s.getDescribe().getName(), new Field((String)s.getDescribe().getLabel(), c.get(s.getDescribe().getName())));
                    
                }
            }  
            
        } catch(Exception e) {
            
        }        
        
        if(event.containsKey('RecordTypeId')) {
            List<RecordType> rTypes = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :(Id)event.get('RecordTypeId').Value];
            if(rTypes != null && rTypes.size() > 0) {
                eventType = rTypes[0].DeveloperName;
            }
        }
        
        if(event.containsKey('Location_Venue__c')) {
            
            List<Account> venues = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account WHERE Id = :(Id)event.get('Location_Venue__c').Value];
            
            if(venues != null && venues.size() > 0) {
                venue = venues[0];
            }
            
        }

        attachments = [SELECT Id, Portal_Title__c, Portal_Description__c, AttachmentID__c, Content_Type__c FROM Attachment__c WHERE Attachment_Type__c = 'Event Resource' AND Event__c = :eventId AND AttachmentID__c != '' AND (Show_in_Portal__c = 'Family' OR Show_in_Portal__c = 'Both')];

    }
    
    public void loadBooking(String eventId) {

        bookings = new Map<String, Map<String,Field>>();
        
        Contact member = portalCore.userContact;
        
        Schema.DescribeSObjectResult objDescribe = Family_Attendance__c.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        String theQuery = 'SELECT ';
        
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        
        String mAccountId = member.AccountId;
        
        theQuery += ' FROM Family_Attendance__c WHERE Family__c = :mAccountId AND Event__c = :eventId ';
        
        try {
            
            for(Family_Attendance__c fa : Database.query(theQuery)) {

                Map<String, Field> booking = new Map<String, Field>();
                
                for(Schema.SObjectField s : fieldMap.values()) {
                    
                    booking.put((String)s.getDescribe().getName(), new Field((String)s.getDescribe().getLabel(), fa.get(s.getDescribe().getName())));
                    
                }

                bookings.put(fa.Id, booking);
                
            }
            
        } catch(Exception ex) {
            
        }
        
    }

    public void loadingRegTypes(String eventId) {
        
        regTypes = new Map<String, Map<String,Field>>();
        
        Contact member = portalCore.userContact;
        
        Schema.DescribeSObjectResult objDescribe = Registration_Type__c.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        String theQuery = 'SELECT ';
        
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        
        String memberId = member.Id;
        
        theQuery += ' FROM Registration_Type__c WHERE Event__c = :eventId ';
        
        try {
            
            for(Registration_Type__c rt : Database.query(theQuery)) {

                Map<String, Field> regType = new Map<String, Field>();
                
                for(Schema.SObjectField s : fieldMap.values()) {
                    
                    regType.put((String)s.getDescribe().getName(), new Field((String)s.getDescribe().getLabel(), rt.get(s.getDescribe().getName())));
                    
                }

                regTypes.put(rt.Id, regType);
                
            }
            
        } catch(Exception ex) {
            
        }

    }
    
    public class Field {
        public String Label {get;set;}
        public Object Value {get;set;}
        
        public Field(String l, Object v) {
            this.Label = l;
            this.Value = v;
        }
    }
    
    public void autoRegister() {
        
        if(ApexPages.currentPage().getParameters().get('register') == 'true')
            register();
        else if(ApexPages.currentPage().getParameters().get('cancel') == 'true')
            cancel();        
        
    }
    
    public String registerBookingId{get;set;}

    public void beginRegistration() {
        
        family = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Home_Phone__c, Mobile_Phone__c, Email__c, Media_Permission_Denied__c, Emergency_Contact__c, Emergency_Contact_Phone__c, Emergency_Contact_Mobile__c, Emergency_Contact_Relationship__c,
                  Media_Permission_Functions__c, Media_Permission_Interviews__c, Media_Permission_Photos__c, Media_Permission_Photo_Share__c, Media_Permission_Pub__c, media_opt_in_take_video_photos__c, media_opt_in_share_participants__c, Media_Opt_in_Public_Sharing__c, Preferred_Event_Locations__c, Family_Interests__c,
                  (SELECT Id, FirstName, LastName, Family_Member_Type__c, Birthdate, Swimming_Ability__c, Shirt_Size__c, Emergency_Contact__c, Emergency_Contact_Phone__c, Emergency_Contact_Mobile__c, Emergency_Contact_Relationship__c FROM Contacts WHERE npsp__Deceased__c = false AND Exclude_From_Portal__c = false)
                  FROM Account WHERE Id = :member.AccountId];
        //DJA 4/5/2017 Added Family_Attendance__c  = :registerBookingId to filter out family members on different family attendances.  
        List<Family_Member_Attendance__c> fmas = [SELECT Id, Attendance__c, Family_Attendance__r.FA_00000__c, Transport_Drop_Off_Location__c, Transport_Pick_Up_Location__c, Transport_Drop_Off_Required__c, Transport_Pick_Up_Required__c, Contact__c, Contact__r.Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Family_Member_Type__c, Contact__r.Birthdate, Contact__r.Swimming_Ability__c, Contact__r.Shirt_Size__c, Contact__r.Emergency_Contact__c, Contact__r.Emergency_Contact_Phone__c, Contact__r.Emergency_Contact_Mobile__c, Contact__r.Emergency_Contact_Relationship__c, OTC_Comments__c  FROM Family_Member_Attendance__c WHERE Family_Attendance__r.Family__c = :family.Id AND Family_Attendance__r.Event__c = :eventId AND Family_Attendance__c  = :registerBookingId AND Contact__r.npsp__Deceased__c = false AND Contact__r.Exclude_From_Portal__c = false];
        
        familyContactMap = new Map<Id,Contact>();
        familyAttendingMap = new Map<Id,Boolean>();

        for(Family_Member_Attendance__c fma : fmas) {
            familyContactMap.put(fma.Contact__c, fma.Contact__r);
            familyAttendingMap.put(fma.Contact__c, fma.Family_Attendance__r.FA_00000__c == 'Invited' ? true : fma.Attendance__c == 'Request to Attend');
        }
        
        isRegistering = true;

        //agreeToParticipate = (Boolean)bookings.get(registerBookingId).get('Agree_to_Participate_in_Event_Activities__c').Value;
        //Family_Member_On_Treatment__c
        givenConsent = (Boolean)bookings.get(registerBookingId).get('Consent__c').Value;
        behavioralExpectations = (Boolean)bookings.get(registerBookingId).get('Behavioral_Expectations__c').Value;
        
        //DJA 16/11/2017
        familyOnTreatment = (Boolean)bookings.get(registerBookingId).get('Family_Member_On_Treatment__c').Value;
        setRegistrationDates();
    }
    
    public Registration_Period__c existingPeriod{get;set;}
    public Map<String, Registration_Period__c> regPeriods{get;set;}
    public Boolean hasRegPeriods{get;set;}
    public String regPeriodId{get;set;}
    
    public void setRegistrationDates() {
        if(String.isNotBlank(registerBookingId) && bookings.containsKey(registerBookingId)) {
            
            String regTypeId = (String)bookings.get(registerBookingId).get('Registration_Type__c').Value;
            
            regPeriods = new Map<String, Registration_Period__c>([SELECT Id, Name, Registrations_Remaining__c 
                                                                  FROM Registration_Period__c
                                                                  WHERE Id IN (SELECT Registration_Period__c 
                                                                               FROM Registration_Type_Period__c 
                                                                               WHERE Registration_Type__c = :regTypeId)
                                                                  AND Registrations_Remaining__c > 0]);
            
            hasRegPeriods = !regPeriods.isEmpty();
            
            List<Registration_Period__c> existingPeriods = [SELECT Id, Name, Registrations_Remaining__c 
                                                            FROM Registration_Period__c
                                                            WHERE Id IN (SELECT Registration_Period__c 
                                                                         FROM Registration_Period_Family_Attendance__c 
                                                                         WHERE Family_Attendance__c = :registerBookingId)];
            
            if(existingPeriods != null && !existingPeriods.isEmpty()) {
                existingPeriod = existingPeriods[0];
                regPeriodId = existingPeriod.Id;
            } else {
                regPeriodId = '';
            }
        }
    }
    
    public List<SelectOption> getRegistrationPeriods() {
        
        List<SelectOption> results = new List<SelectOption>();
        results.add(new SelectOption('', '--Please Select--'));
        
        if(hasRegPeriods) {
            
            if(existingPeriod != null && !regPeriods.containsKey(existingPeriod.Id)) {
                results.add(new SelectOption(existingPeriod.Id, existingPeriod.Name));
            }
            
            for(String key : regPeriods.keySet()) {
                results.add(new SelectOption(key, regPeriods.get(key).Name));
            }
            
        }
        
        return results;
        
    }
    
    public Id editContactId{get;set;}
    public Contact currentContact{get;set;}
    public Family_Member_Attendance__c currentFMA{get;set;}
    public String currentFMACelebration{get;set;}
    public Map<String, Special_Needs__c> currentNeeds{get;set;}
    public Integer countNeeds{get;set;}

    public String currentlyOnTreatment{
        get{
            if(currentFMA != null) {
                return currentFMA.Currently_on_Treatment__c;
            }

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Currently_on_Treatment__c = value;
        }
    }
    public List<SelectOption> getCurrentlyOnTreatmentOptions() {
        Schema.DescribeFieldResult fieldResult = Family_Member_Attendance__c.Currently_on_Treatment__c.getDescribe();
        return fieldOptions(fieldResult);
    }

    public String hasCentralLine{
        get{
            if(currentFMA != null) {
                return currentFMA.Has_Central_Line__c;
            }

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Has_Central_Line__c = value;
        }
    }
    public List<SelectOption> getHasCentralLineOptions() {
        Schema.DescribeFieldResult fieldResult = Family_Member_Attendance__c.Has_Central_Line__c.getDescribe();
        return fieldOptions(fieldResult);
    }

    public String hasPortacath{
        get{
            if(currentFMA != null) {
                return currentFMA.Has_Portacath__c;
            }

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Has_Portacath__c = value;
        }
    }
    public List<SelectOption> getHasPortacathOptions() {
        Schema.DescribeFieldResult fieldResult = Family_Member_Attendance__c.Has_Portacath__c.getDescribe();
        return fieldOptions(fieldResult);
    }

    public String requiresMedicationOrVitamins{
        get{
            if(currentFMA != null) {
                return currentFMA.Requires_Medication_or_Vitamins__c;
            } 

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Requires_Medication_or_Vitamins__c = value;
        }
    }
    public List<SelectOption> getRequiresMedicationOrVitaminsOptions() {
        Schema.DescribeFieldResult fieldResult = Family_Member_Attendance__c.Requires_Medication_or_Vitamins__c.getDescribe();
        return fieldOptions(fieldResult);
    }
    public String OTC_Comments {
        get{
            if(currentFMA != null) {
                return currentFMA.OTC_Comments__C;
            } 

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.OTC_Comments__C = value;
        
        }
    }
    public String pickupRequired{
        get{
            if(currentFMA != null) {
                return currentFMA.Transport_Pick_Up_Required__c;
            } 
            
            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Transport_Pick_Up_Required__c = value;
        }
    }
    public String pickupLocation{
        get{
            if(currentFMA != null) {
                return currentFMA.Transport_Pick_Up_Location__c;
            } 

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Transport_Pick_Up_Location__c = value;
        }
    }
    public List<SelectOption> getPickupLocationOptions() {
        String locs = (String)event.get('Available_Getting_to_Camp_Locations__c').Value;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Please Select--'));
        
        if(locs != null && String.isNotBlank(locs)) {
            for(String loc : locs.split(';')) {
                options.add(new SelectOption(loc,loc));
            }
        }
        
        return options;
    }
    
    public String dropOffRequired{
        get{
            if(currentFMA != null) {
                return currentFMA.Transport_Drop_Off_Required__c;
            } 
            
            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Transport_Drop_Off_Required__c = value;
        }
    }
    public String dropOffLocation{
        get{
            if(currentFMA != null) {
                return currentFMA.Transport_Drop_Off_Location__c;
            } 

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Transport_Drop_Off_Location__c = value;
        }
    }
    public List<SelectOption> getDropOffLocationOptions() {
        String locs = (String)event.get('Available_Getting_Home_Locations__c').Value;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Please Select--'));
        
        if(locs != null && String.isNotBlank(locs)) {
            for(String loc : locs.split(';')) {
                options.add(new SelectOption(loc,loc));
            }
        }
        
        return options;
    }
    
    
    //DJA 17/02/2017 Added new fields for immunisation and OTC meds
    
    public String Child_Immunisation_Schedule_Current{
        get{
            if(currentFMA != null) {
                return currentFMA.Child_Immunisation_Schedule_Current__c;
            } 

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Child_Immunisation_Schedule_Current__c = value;
        }
    }
    public List<SelectOption> getChild_Immunisation_Schedule_Current_Options() {
        Schema.DescribeFieldResult fieldResult = Family_Member_Attendance__c.Child_Immunisation_Schedule_Current__c.getDescribe();
        return fieldOptions(fieldResult);
    }
    
    public String OTC_Standard{
        get{
            if(currentFMA != null) {
                return currentFMA.OTC_Standard__c;
            } 

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.OTC_Standard__c = value;
        }
    }
    public List<SelectOption> getOTC_Standard_Options() {
        Schema.DescribeFieldResult fieldResult = Family_Member_Attendance__c.OTC_Standard__c.getDescribe();
        return fieldOptions(fieldResult);
    }
    

    public String medicationAndVitamins{
        get{
            if(currentFMA != null) {
                return currentFMA.Medication_and_Vitamins__c;
            }

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value))
                currentFMA.Medication_and_Vitamins__c = value;
        }
    }

    public String LastDoseOfChemoDate{
        get{
            if(currentFMA != null && currentFMA.Last_Chemo_Dose_Date__c != null) {
                return currentFMA.Last_Chemo_Dose_Date__c.format();
            }

            return null;
        }
        set {
            if(currentFMA != null && String.isNotEmpty(value)) {
                try {
                    currentFMA.Last_Chemo_Dose_Date__c = Date.parse(value);
                } catch(Exception e) {}
            }
        }
    }

    public void editContact() {
        successMsg = '';
        errorMsg = '';
        
        if(String.isNotEmpty(editContactId) && familyContactMap.containsKey(editContactId)) {
            currentContact = familyContactMap.get(editContactId);
            //DJA 17/02/2017 add Child_Immunisation_Schedule_Current__c and OTC_Standard__c
            List<Family_Member_Attendance__c> fmas = [SELECT Id, Special_Celebration__c, Last_Chemo_Dose_Date__c, Medication_and_Vitamins__c, Requires_Medication_or_Vitamins__c, Has_Portacath__c, Transport_Drop_Off_Location__c, Transport_Pick_Up_Location__c, Transport_Drop_Off_Required__c, Transport_Pick_Up_Required__c, Has_Central_Line__c, Currently_on_Treatment__c,OTC_Standard__c, Child_Immunisation_Schedule_Current__c,OTC_Comments__C FROM Family_Member_Attendance__c WHERE Family_Attendance__c = :registerBookingId AND Contact__c = :editContactId];
            
            if(fmas != null && fmas.size() > 0) {
                currentFMA = fmas[0];
            }
        }
        
        currentNeeds = new Map<String, Special_Needs__c>();
        countNeeds = 0;
        Boolean hasDiet = false;
        Boolean hasNeeds = false;
        
        for(Special_Needs__c sn : [SELECT Id, AttributeType__c, Comments__c, Contact__c, Date__c, Long_Description__c FROM Special_Needs__c WHERE Contact__c = :editContactId]) {
            if(sn.AttributeType__c == 'DietryNeeds') {
                hasDiet = true;
            } else if(sn.AttributeType__c == 'SpecialNeeds') {
                hasNeeds = true;
            }
            
            currentNeeds.put(sn.Id, sn);
        }
        
        if(!hasDiet) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = editContactId, Date__c = Date.today());

            if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
                sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }
        
        if(!hasNeeds) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'SpecialNeeds', Contact__c = editContactId, Date__c = Date.today());
            
            if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
                sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);
            
            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }

        System.debug('currentNeeds: ' + currentNeeds);
        
    }
    
    public void saveContact() {
        
        if(String.isNotEmpty(currentFMACelebration)) {
            currentFMA.Special_Celebration__c = currentFMACelebration;
        }
        
        try {
            
            update currentContact;
            update currentFMA;
            
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
        
        currentContact = null;
        currentNeeds = null;
        
        successMsg = 'Family member updated successfully.';
        
    }
    
    public void cancelContact() {
        
        currentContact = null;
        currentNeeds = null;
        
    }
    
    public String addType{get;set;}
    
    public void addSpecialNeed() {

        if(currentNeeds != null && String.isNotEmpty(addType)) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = addType, Contact__c = editContactId, Date__c = Date.today());

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
    
    public void register() {
        
        List<Family_Attendance__c> fas = [SELECT Id, FA_00000__c, Agree_to_Participate_in_Event_Activities__c, Consent__c, Behavioral_Expectations__c FROM Family_Attendance__c WHERE Id = :registerBookingId];
        Family_Attendance__c fa;

        if(fas == null || fas.size() == 0) {
            errorMsg = 'Unable to retrieve invitation.';
            return;
        }
        
        fa = fas[0];
        
        if(fa.FA_00000__c == 'Invited') {
        	fa.FA_00000__c = 'Request to Attend';
        }   
        
        //fa.Agree_to_Participate_in_Event_Activities__c = agreeToParticipate;
        fa.Consent__c = givenConsent;
        fa.Behavioral_Expectations__c = behavioralExpectations;
        fa.Family_Member_On_Treatment__c = familyOnTreatment;
        
        List<Family_Member_Attendance__c> fmas = [SELECT Id, Attendance__c, Contact__c FROM Family_Member_Attendance__c WHERE Family_Attendance__c = :fa.Id AND Contact__r.Exclude_From_Portal__c = false AND Contact__r.npsp__Deceased__c = false];
        List<Family_Member_Attendance__c> updateFMAs = new List<Family_Member_Attendance__c>();
        
        for(Family_Member_Attendance__c fma: fmas) {
            if(familyAttendingMap.containsKey(fma.Contact__c)) {
                fma.Attendance__c = familyAttendingMap.get(fma.Contact__c) ? 'Request to Attend' : 'Declined';
                updateFMAs.add(fma);
            }
        }
            
        try {
            
            update fa;
            update updateFMAs;
            
        } catch (Exception e) {
            
            ApexPages.addMessages(e);
            return;
            
        }
        
        try {
            
            update family;
            
        } catch (Exception e) {
            
            ApexPages.addMessages(e);
            return;
            
        }
        
        if(String.isNotBlank(regPeriodId) && (existingPeriod == null || existingPeriod.Id != regPeriodId)) {
            if(existingPeriod != null) {
                
                List<Registration_Period_Family_Attendance__c> rpfa = [SELECT Id FROM Registration_Period_Family_Attendance__c WHERE Family_Attendance__c = :fa.Id AND Registration_Period__c = :existingPeriod.Id];
                if(!rpfa.isEmpty()) {
                    try {
                        delete rpfa;
                    } catch(DmlException e) {
                        System.debug(e);
                        ApexPages.addMessages(e);
                        return;
                    }
                }
            } 
            
            try {
                insert new Registration_Period_Family_Attendance__c(
                    Family_Attendance__c = fa.Id,
                    Registration_Period__c = regPeriodId
                );
            } catch(DmlException e) {
                System.debug(e);
                ApexPages.addMessages(e);
                return;
            }
        }
        
        
        /*pageReference pageRef = portalCore.pageLink('My Events');
        System.debug(pageRef);
        pageRef.getParameters().put('raction', 'booking');
        
        return pageRef;*/

        isRegistering = false;
        successMsg = 'Thank you for registering for this event.';
        
    }

    public String cancelBookingId{get;set;}
    
    public void declined() {
        
        List<Family_Attendance__c> fas = [SELECT Id, FA_00000__c, Agree_to_Participate_in_Event_Activities__c, (SELECT Id, Attendance__c FROM Family_Member_Attendance__r) FROM Family_Attendance__c WHERE Id = :cancelBookingId];
        
        if(fas != null && fas.size() > 0) {
            
            Family_Attendance__c fa = fas[0];
            
            fa.FA_00000__c = 'Declined';
            fa.Cancellation_Reason__c = (String)bookings.get(cancelBookingId).get('Cancellation_Reason__c').Value;
            
            try {
                
                update fas;
                
            } catch (Exception e) {
                
                ApexPages.addMessages(e);
                return;
            }
            
            if(fa.Family_Member_Attendance__r != null && fa.Family_Member_Attendance__r.size() > 0) {
                
                List<Family_Member_Attendance__c> fmas = fa.Family_Member_Attendance__r;
                
                for(Family_Member_Attendance__c fma : fmas) {
                    fma.Attendance__c = 'Declined';
                }
                
                try {
                    
                    update fmas;
                    
                } catch (Exception e) {
                    
                    ApexPages.addMessages(e);
                    return;
                }
                    
            }
            
            
        }
        
        /*pageReference pageRef = portalCore.pageLink('My Events');
        System.debug(pageRef);
        pageRef.getParameters().put('raction', 'cancel');
        
        return pageRef;*/

        isRegistering = false;
        successMsg = 'Booking Declined.';
        
    }
    
    public void cancel() {
        
        List<Family_Attendance__c> fas = [SELECT Id, FA_00000__c, Agree_to_Participate_in_Event_Activities__c, (SELECT Id, Attendance__c FROM Family_Member_Attendance__r) FROM Family_Attendance__c WHERE Id = :cancelBookingId];
        
        if(fas != null && fas.size() > 0) {
            
            Family_Attendance__c fa = fas[0];
            
            fa.FA_00000__c = 'Cancelled';
            fa.Cancellation_Reason__c = (String)bookings.get(cancelBookingId).get('Cancellation_Reason__c').Value;
            
            try {
                
                update fas;
                
            } catch (Exception e) {
                
                ApexPages.addMessages(e);
                return;
            }
            
            if(fa.Family_Member_Attendance__r != null && fa.Family_Member_Attendance__r.size() > 0) {
                
                List<Family_Member_Attendance__c> fmas = fa.Family_Member_Attendance__r;
                
                for(Family_Member_Attendance__c fma : fmas) {
                    fma.Attendance__c = 'Cancelled';
                }
                
                try {
                    
                    update fmas;
                    
                } catch (Exception e) {
                    
                    ApexPages.addMessages(e);
                    return;
                }
                    
            }
            
            
        }
        
        /*pageReference pageRef = portalCore.pageLink('My Events');
        System.debug(pageRef);
        pageRef.getParameters().put('raction', 'cancel');
        
        return pageRef;*/

        isRegistering = false;
        successMsg = 'Registration Cancelled.';
        
    }

    private List<SelectOption> fieldOptions(Schema.DescribeFieldResult fr) {
        List<Schema.PicklistEntry> ple = fr.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();

        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }   

       return options;
    }
    
}