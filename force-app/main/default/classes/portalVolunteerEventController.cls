public class portalVolunteerEventController {
    
    
    public String eventId {get;set;}
    public Boolean eventOff {get;set;}
    public Boolean isRegistering {get;set;}
    
    public Account family{get;set;}
    public Map<Id,Contact> familyContactMap{get;set;}
    public Map<Id, Boolean> familyAttendingMap{get;set;}
    
    public Boolean agreeToParticipate{get;set;}
    
    public String eventType{get;set;}
    
    public Contact member {get;set;}
    public Account venue {get;set;}
    
    public String successMsg{get;set;}
    public String errorMsg{get;set;}

    public List<Attachment__c> attachments{get;set;}
    public Map<Id, ContentDistribution> contentDists{get;set;}

    public Map<String, Id> specialNeedRTs{get;set;}
    
    public Boolean hasSuccess{get{ return String.isNotEmpty(successMsg); }set;}
    public Boolean hasError{get{ return ApexPages.hasMessages() || String.isNotEmpty(errorMsg); }set;}    
    
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
    
    public portalVolunteerEventController() {
        
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

        attachments = [SELECT Id, Portal_Title__c, Portal_Description__c, AttachmentID__c, Content_Type__c FROM Attachment__c WHERE Attachment_Type__c = 'Event Resource' AND Event__c = :eventId AND AttachmentID__c != '' AND (Show_in_Portal__c = 'Volunteer' OR Show_in_Portal__c = 'Both')];

        List<String> attachmentIds = new List<String>();

        for(Attachment__c a : attachments) {
            if(a.Content_Type__c == 'File')
                attachmentIds.add(a.AttachmentID__c);
        }

        /*if(!Test.isRunningTest()) {
         
            List<ContentDistribution> contentDList = [SELECT Id, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution WHERE ContentDocumentId IN :attachmentIds];

            System.debug('contentDList: ' + contentDList);

            contentDists = new Map<Id, ContentDistribution>();

            for(ContentDistribution cd : contentDList) {
                contentDists.put(cd.ContentDocumentId, cd);
            }

            System.debug('contentDists: ' + contentDists);

        }*/
    }
    
    public void loadBooking(String eventId) {
        
        bookings = new Map<String, Map<String,Field>>();
        
        Contact member = portalCore.userContact;
        
        Schema.DescribeSObjectResult objDescribe = Volunteer_Attendance__c.sObjectType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        String theQuery = 'SELECT ';
        
        for(Schema.SObjectField s : fieldMap.values()) 
            theQuery += s.getDescribe().getName() + ',';
        
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        
        String memberId = member.Id;
        
        theQuery += ' FROM Volunteer_Attendance__c WHERE Volunteer__c = :memberId AND Event__c = :eventId ';
        
        try {
            
            for(Volunteer_Attendance__c va : Database.query(theQuery)) {

            	Map<String, Field> booking = new Map<String, Field>();
                
                for(Schema.SObjectField s : fieldMap.values()) {
                    
                    booking.put((String)s.getDescribe().getName(), new Field((String)s.getDescribe().getLabel(), va.get(s.getDescribe().getName())));
                    
                }

                bookings.put(va.Id, booking);
                
            }
            
        } catch(Exception ex) {
            
        }
        
        //agreeToParticipate = (Boolean)booking.get('Agree_to_Participate_in_Event_Activities__c').Value;
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
        
        //agreeToParticipate = (Boolean)booking.get('Agree_to_Participate_in_Event_Activities__c').Value;
    }
    
    public class Field {
        public String Label {get;set;}
        public Object Value {get;set;}
        
        public Field(String l, Object v) {
            this.Label = l;
            this.Value = v;
        }
    }
    
    public pageReference autoRegister() {
        
        if(ApexPages.currentPage().getParameters().get('register') == 'true')
            return null;// register();
        else if(ApexPages.currentPage().getParameters().get('cancel') == 'true')
            return null;// cancel();
        else
            return null;
        
    }
    
    public String registerBookingId{get;set;}
    public Map<String, Special_Needs__c> currentNeeds{get;set;}
    public Integer countNeeds{get;set;}

    public void beginRegistration() {

    	successMsg = '';
        errorMsg = '';
        
        currentNeeds = new Map<String, Special_Needs__c>();
        countNeeds = 0;
        Boolean hasDiet = false;
        Boolean hasNeeds = false;
        
        for(Special_Needs__c sn : [SELECT Id, AttributeType__c, Comments__c, Contact__c, Date__c, Long_Description__c FROM Special_Needs__c WHERE Contact__c = :member.Id]) {
            if(sn.AttributeType__c == 'DietryNeeds') {
                hasDiet = true;
            } else if(sn.AttributeType__c == 'SpecialNeeds') {
                hasNeeds = true;
            }
            
            currentNeeds.put(sn.Id, sn);
        }
        
        if(!hasDiet) {

        	Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Contact__c = member.Id, Date__c = Date.today());

        	if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
        		sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }
        
        if(!hasNeeds) {

        	Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'SpecialNeeds', Contact__c = member.Id, Date__c = Date.today());
        	
        	if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
        		sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);
        	
            currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        }
        
        isRegistering = true;
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
                                                                         FROM Registration_Period_Volunteer_Attendance__c 
                                                                         WHERE Volunteer_Attendance__c = :registerBookingId)];
            
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
            
    public String addType{get;set;}
    
    public void addSpecialNeed() {
        if(currentNeeds != null && String.isNotEmpty(addType)) {

        	Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = addType, Contact__c = member.Id, Date__c = Date.today());

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
        
        List<Volunteer_Attendance__c> vas = [SELECT Id, Attendance__c FROM Volunteer_Attendance__c WHERE Id = :registerBookingId];
        Volunteer_Attendance__c va;

        if(vas == null || vas.size() == 0) {
            errorMsg = 'Unable to retrieve invitation.';
            return;
        }
        
        va = vas[0];
        
        if(va.Attendance__c == 'Invited') {
        	va.Attendance__c = 'Request to Attend';

        	if(bookings.containsKey(registerBookingId) && registerBookingId InstanceOf Id)
        		bookings.get((Id)registerBookingId).get('Attendance__c').Value = 'Request to Attend';
        }   
        
        //va.Agree_to_Participate_in_Event_Activities__c = agreeToParticipate;
            
        try {
            
            update va;
            
        } catch (Exception e) {
            
            ApexPages.addMessages(e);
            return;
            
        }
        
        try {
            
            update member;
            
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
        
        if(String.isNotBlank(regPeriodId) && (existingPeriod == null || existingPeriod.Id != regPeriodId)) {
            if(existingPeriod != null) {
                
                List<Registration_Period_Volunteer_Attendance__c> rpva = [SELECT Id FROM Registration_Period_Volunteer_Attendance__c WHERE Volunteer_Attendance__c = :va.Id AND Registration_Period__c = :existingPeriod.Id];
                if(!rpva.isEmpty()) {
                    try {
                        delete rpva;
                    } catch(DmlException e) {
                        System.debug(e);
                        ApexPages.addMessages(e);
                        return;
                    }
                }
            } 
            
            try {
                insert new Registration_Period_Volunteer_Attendance__c(
                    Volunteer_Attendance__c = va.Id,
                    Registration_Period__c = regPeriodId
                );
            } catch(DmlException e) {
                System.debug(e);
                ApexPages.addMessages(e);
                return;
            }
        }
        
        /*pageReference pageRef = portalCore.pageLink('Volunteer My Events');
        System.debug(pageRef);
        pageRef.getParameters().put('raction', 'booking');
        
        return pageRef;*/

        isRegistering = false;
        successMsg = 'Thank you for registering for this event.';
        
    }

    public String cancelBookingId{get;set;}

     public void declined() {
        
        List<Volunteer_Attendance__c> vas = [SELECT Id, Attendance__c, Cancellation_Reason__c FROM Volunteer_Attendance__c WHERE Id = :cancelBookingId];
        
        if(vas != null && vas.size() > 0) {
            
            Volunteer_Attendance__c va = vas[0];
            
            va.Attendance__c = 'Declined';
            va.Cancellation_Reason__c = (String)bookings.get(cancelBookingId).get('Cancellation_Reason__c').Value;

            if(bookings.containsKey(cancelBookingId) && cancelBookingId InstanceOf Id)
        		bookings.get((Id)cancelBookingId).get('Attendance__c').Value = 'Declined';
            
            try {
                
                update vas;
                
            } catch (Exception e) {
                
                ApexPages.addMessages(e);
                return;

            }
            
        }

        successMsg = 'Booking Declined.';
        
        /*pageReference pageRef = portalCore.pageLink('My Events');
        System.debug(pageRef);
        pageRef.getParameters().put('raction', 'cancel');
        
        return pageRef;*/
        
    }
    
    public void cancel() {
        
        List<Volunteer_Attendance__c> vas = [SELECT Id, Attendance__c, Cancellation_Reason__c FROM Volunteer_Attendance__c WHERE Id = :cancelBookingId];
        
        if(vas != null && vas.size() > 0) {
            
            Volunteer_Attendance__c va = vas[0];
            
            va.Attendance__c = 'Cancelled';
            va.Cancellation_Reason__c = (String)bookings.get(cancelBookingId).get('Cancellation_Reason__c').Value;

            if(bookings.containsKey(cancelBookingId) && cancelBookingId InstanceOf Id)
        		bookings.get((Id)cancelBookingId).get('Attendance__c').Value = 'Cancelled';
            
            try {
                
                update vas;
                
            } catch (Exception e) {
                
                ApexPages.addMessages(e);
                return;

            }
            
        }

        successMsg = 'Registration cancelled.';
        
        /*pageReference pageRef = portalCore.pageLink('My Events');
        System.debug(pageRef);
        pageRef.getParameters().put('raction', 'cancel');
        
        return pageRef;*/
        
    }
    
}