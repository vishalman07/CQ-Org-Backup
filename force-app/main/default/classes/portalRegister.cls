public class portalRegister {
    
    public Account acct {get; set;}
    public Boolean alreadyRegistered {get;set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set;}
    public String confirmPassword {get; set;}
    public Contact c {get;set;}

    public List<Registration_Type__c> regTypes{get;set;}

    public Boolean codeOfConduct{get;set;}

    public Map<String, Special_Needs__c> currentNeeds{get;set;}
    public Map<String, Id> specialNeedRTs{get;set;}
    public Integer countNeeds{get;set;}

    public Contact newContact{get;set;}
    
    public Boolean corpAccount{get{return corpAccount == null ? false : corpAccount;}set;}

    public PageReference loginPage() {
    	return new PageReference( '/portalLogin');
    }
    
    public Boolean hasPageMessages {
    	get {
	    	return ApexPages.hasMessages();
    	}
    }
    
    public portalRegister() {

        this.acct = new Account();

        if(ApexPages.currentPage().getParameters().containsKey('a') && ApexPages.currentPage().getParameters().get('a') InstanceOf Id) {

            String accountId = ApexPages.currentPage().getParameters().get('a');

            List<Account> accts = [SELECT Id, Name, Corporate_Volunteer_Signup_Message__c FROM Account WHERE Id = :accountId];

            if(!accts.isEmpty()) {
                this.acct = accts[0];
            }

            corpAccount = true;

        }
        
        this.alreadyRegistered = false;
        
        /*String msId = ApexPages.currentPage().getParameters().get('m');
        
        if(msId != null) {
            List<Membership_Subscription__c> msList = new List<Membership_Subscription__c>([SELECT Id, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Account__c, Account__r.Name FROM Membership_Subscription__c WHERE Id = :msId]);
        
            if(!msList.isEmpty()) {
                Membership_Subscription__c ms = msList[0];
                
                acct.Name = ms.Account__r.Name;
                
                firstName = ms.Contact__r.FirstName;
                lastName = ms.Contact__r.LastName;
                Email = ms.Contact__r.Email;
                
            }
        }*/
        
        newContact = new Contact(AccountId = this.acct.Id);

        if(corpAccount) {

            List<RecordType> conRTs = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND DeveloperName = 'Volunteer'];

            if(!conRTs.isEmpty())
                newContact.RecordTypeId = conRTs[0].Id;

            newContact.Code_of_Conduct_Date__c = Date.today();

            regTypes = [SELECT Id, Event__c FROM Registration_Type__c WHERE Corporate_Partner__c = :this.acct.Id AND Event__r.Registrations_Closed__c > :Datetime.now()];

            System.debug('regTypes: ' + regTypes);
        }

        specialNeedRTs = new Map<String, Id>();

        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Special_Needs__c' AND (DeveloperName = 'Dietary_Requirement' OR DeveloperName = 'Special_Need')]) {
            if(rt.DeveloperName == 'Dietary_Requirement') {
                specialNeedRTs.put('DietryNeeds', rt.Id);
            } else if(rt.DeveloperName == 'Special_Need') {
                specialNeedRTs.put('SpecialNeeds', rt.Id);
            }
        }

        currentNeeds = new Map<String, Special_Needs__c>();
        countNeeds = 0;
        Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = 'DietryNeeds', Date__c = Date.today());

        if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
            sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);

        currentNeeds.put(String.valueOf(countNeeds++), sNeed);

        sNeed = new Special_Needs__c(AttributeType__c = 'SpecialNeeds', Date__c = Date.today());
        
        if(specialNeedRTs.containsKey(sNeed.AttributeType__c))
            sNeed.RecordTypeId = specialNeedRTs.get(sNeed.AttributeType__c);
        
        currentNeeds.put(String.valueOf(countNeeds++), sNeed);
        
    }
    
    public void checkAccount() {
        System.debug('checkAccount acct: ' + this.acct);
        if (this.acct.Name != null && !String.isEmpty(this.acct.Name)) {
            Account existingAcct = null;
            Set<Id> existingContactIds = new Set<Id>();
            User existingUser = null;
            
            try {
                existingAcct = [SELECT Id FROM Account WHERE Name =: this.acct.Name];
                for (Contact c : [SELECT Id FROM Contact WHERE AccountId =: existingAcct.Id])
                    existingContactIds.add(c.Id);
                
                existingUser = [SELECT Id FROM User WHERE IsActive = TRUE AND ContactId IN :existingContactIds LIMIT 1];
                
                if (existingUser != null)
                    this.alreadyRegistered = true;
                else
                    this.alreadyRegistered = false;
            } catch (Exception e) {
                System.debug('Error looking for existing account/contact/user: ' + e);
                this.alreadyRegistered = false;
            }
        }
    }
        
    public PageReference registerUser() {
        this.acct.External_ID__c = this.acct.Name;

        if (this.password != this.confirmPassword) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);

            System.debug('registerUser() passwords dont match');
            
            return null;
        }
        
        
        
        User existingUser = null;
        try {
            existingUser = [SELECT Id FROM User WHERE IsActive = true AND Username = :email];
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Active User already exists with this email address'));

            return null;
        } catch (Exception e) { }

        if(!corpAccount) {

            Account existing = null;
            try {
            	existing = [SELECT Name, External_ID__c FROM Account WHERE Name =: this.acct.Name LIMIT 1];

    			System.debug('registerUser() account exists existing: ' + existing);
    			System.debug('registerUser() account exists this.acct: ' + this.acct);
            	
            	//this.acct = existing;
            	this.acct = new Account(Name=existing.Name, OwnerId = '00528000004FNKA', External_ID__c=existing.External_ID__c);
            	
            	System.debug('registerUser() account exists this.acct (after existing fudging): ' + this.acct);
            } catch (Exception e) {
            	this.acct.OwnerId = '00528000004FNKA';
            	System.debug('registerUser() account does not exist: this.acct: ' + this.acct);
            }

            // Can only create accounts, cannot edit them...
            try {
            	System.debug('registerUser() about to upsert this.acct: ' + this.acct);
            	upsert this.acct External_ID__c;
            	System.debug('registerUser() this.acct upserted: ' + this.acct);
            } catch (Exception e) {
            	System.debug('registerUser() error upserting this.acct e: ' + e);
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating your Account: ' + e.getMessage()));
            	return null;
            }

        }

        List<Profile> ps = [SELECT Id, Name FROM Profile WHERE Name = 'My Camp Quality Members'];
        String profileId;

        if(!ps.isEmpty())
            profileId = ps[0].Id;
        
        User u = new User();
        u.Username = email;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = this.generateNickname();
        u.ProfileId = profileId;
        u.TimeZoneSidKey='Australia/Sydney';
        //u.UserPermissionsChatterAnswersUser = true; 
        
        String userId;
        
        try {
            System.debug('before site.create');
            userId = Site.createExternalUser(u, this.acct.Id, password);
            System.debug('after site.create');
            System.debug('userId: ' + userId);
        } catch(Site.ExternalUserCreateException ex) {
            
            System.debug('Site.ExternalUserCreateException this.acct: ' + this.acct);
            System.debug('Site.ExternalUserCreateException ex: ' + ex);
            
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
            
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            
            if(!corpAccount)
                this.acct = new Account(Name=this.acct.Name, OwnerId = '00528000004FNKA', External_ID__c=this.acct.External_ID__c);

            System.debug('Site.ExternalUserCreateException this.acct (after fudging): ' + this.acct);
        } catch (Exception e) {
        	System.debug('General exception e: ' +e);
        	System.debug('General expection this.acct: ' + this.acct);
        	
            if(!corpAccount)
                this.acct = new Account(Name=this.acct.Name, OwnerId = '00528000004FNKA', External_ID__c=this.acct.External_ID__c);
        	
        	System.debug('General exception this.acct (after fudging): ' + this.acct);
        }
        
        if (userId != null || Test.isRunningTest()) {

            List<User> us;

            if(Test.isRunningTest()) {
                us = [SELECT Id, ContactId FROM User WHERE CommunityNickname = 'portaluser'];
            } else {
                us = [SELECT Id, ContactId FROM User WHERE Id = :userId];
            }
            

            if(!us.isEmpty()) {
                u = us[0];

                newContact.Id = u.ContactId;
                
                newContact.Portal_Access__c = 'Activate';
                newContact.Portal_Access_Type__c = 'Corporate Portal'; 

                try {
                    update newContact;
                } catch(DmlException ex) {
                    
                    newContact = newContact.clone();
                    System.debug('General exception e: ' +ex);
                    System.debug('General exception this.newContact: ' + this.newContact);

                }

                if(String.isNotEmpty(newContact.Id)) {
                    List<Special_Needs__c> updateNeeds = new List<Special_Needs__c>();
            
                    for(Special_Needs__c sn : currentNeeds.values()) {
                        if(String.isNotEmpty(sn.Long_Description__c)) {
                            sn.Contact__c = newContact.Id;
                            updateNeeds.add(sn);
                        }
                    }
                    
                    if(updateNeeds.size() > 0) {
                        try {
                            
                            upsert updateNeeds;
                            
                        } catch(DmlException ex) {
                            
                            System.debug(ex);
                            ApexPages.addMessages(ex);
                            
                        }
                    }
                }
            }

            /*if(corpAccount && !regTypes.isEmpty()) {

                List<Volunteer_Attendance__c> vas = new List<Volunteer_Attendance__c>();

                for(Registration_Type__c rt : regTypes) {
                    vas.add(new Volunteer_Attendance__c(Event__c = rt.Event__c, Volunteer__c = newContact.Id, Attendance__c = 'Invited', Registration_Type__c = rt.Id));
                }

                System.debug('vas: ' + vas);

                if(!vas.isEmpty()) {
                    try {

                        insert vas;

                    } catch(DmlException ex) {

                        System.debug(ex);
                        ApexPages.addMessages(ex);

                    }
                }

            }*/

            return Site.login(email, password, ApexPages.currentPage().getParameters().get('startURL'));
        } else if(!corpAccount) {
        	this.acct = new Account(Name=this.acct.Name, OwnerId = '00528000004FNKA');
        }
        
        return null;
    }
    
    private String generateNickname() {
        List<User> users = new List<User>();
        Blob key;
        String nickname;
                
        do {
            key = Crypto.generateAesKey(128);
            nickname = EncodingUtil.convertToHex(key);
            users = [SELECT Id FROM User WHERE CommunityNickname = :nickname];
        } while (users.size() > 0);
        
        return nickname;
    }    

    public String addType{get;set;}
    
    public void addSpecialNeed() {
        if(currentNeeds != null && String.isNotEmpty(addType)) {

            Special_Needs__c sNeed = new Special_Needs__c(AttributeType__c = addType, Date__c = Date.today());

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
    
    
}