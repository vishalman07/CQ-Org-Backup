@isTest
private class PortalContactTests
{
    public static testMethod void testContactPortalAccessTrigger() {
        Account a = new Account(Name='Johnny Boys');
        insert a;

        Contact c = new Contact(FirstName='Johnny', LastName='Doey', Email='johnny@doey.org', Portal_Access__c='Activate', AccountId=a.Id);
        //c.External_ID__c = c.FirstName.substring(0, 1) + c.LastName + c.Email;

        Test.startTest();

        insert c;

        Test.stopTest();
    }

    public static testMethod void testContactPortalStatusQueueable() {

        Map<String, RecordType> rMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType]){
            rMap.put(r.DeveloperName, r);
        }
            
        Account a = New Account( Name = 'Family', RecordTypeId = rMap.get('Family').Id, Family_Type__c = 'Patient',Regionv2__c='ACT - Albury', Preferred_Event_Locations__c='Sydney', Family_Interests__c = 'Sports');
        insert a;

        List<Contact> cons = new List<Contact>{
            new Contact(FirstName='A', LastName='B', Email='a@b.org', AccountId=a.Id),
            new Contact(FirstName='C', LastName='D', Email='c@d.org', AccountId=a.Id)
        };

        insert cons;

        Set<Id> conIds = new Set<Id>{cons[0].Id, cons[1].Id};

/*      for (Contact c : cons)
            c.Anemia__c = true;

        Test.startTest();

        System.enqueueJob(new ContactPortalStatus(cons));

        Test.stopTest();

        cons = [SELECT Id, Anemia__c FROM Contact WHERE Id IN :cons];

        for (Contact c : cons)
            System.assert(c.Anemia__c);*/
    }

    public static testMethod void testContactPortalToggle() {
        User runningUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        User existingActive;
        User existingDisabled;

        Account a = new Account(Name='No User Yet');
        
        User noRoleUser = [SELECT Id FROM User WHERE UserRoleId = '' AND IsActive = true LIMIT 1];
        if (noRoleUser != null)
            a.OwnerId = '0052x0000027zI6';
        insert a;

        System.debug('a (norole?): ' + a);

        Contact noUserYet = new Contact(FirstName='No', LastName='User', Email='No@User.org', AccountId=a.Id);
        insert noUserYet;

        System.runAs(runningUser) {
            existingActive = createUser(true);
            existingDisabled = createUser(false);

            Contact existingAc = [SELECT Id, Portal_Access__c FROM Contact WHERE Id =: existingActive.ContactId];
            Contact existingDis = [SELECT Id, Portal_Access__c FROM Contact WHERE Id =: existingDisabled.ContactId];

            existingAc.Portal_Access__c = 'Deactivate';
            existingDis.Portal_Access__c = 'Activate';
            noUserYet.Portal_Access__c = 'Activate';

            Test.startTest();

            System.enqueueJob(new ContactPortalToggle(new List<Contact>{existingAc, existingDis, noUserYet}));

            Test.stopTest();
        }
    }

    public static testMethod void testContactPortalToggleError() {
        

        Map<String, RecordType> rMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType]){
            rMap.put(r.DeveloperName, r);
        }
            
        Account a = New Account( Name = 'Family', RecordTypeId = rMap.get('Family').Id, Family_Type__c = 'Patient',Regionv2__c='ACT - Albury', Preferred_Event_Locations__c='Sydney', Family_Interests__c = 'Sports');
        insert a;

        Contact c = new Contact(LastName='BOOM', AccountId = a.Id); // will fail PortalContactUtility.ValidateContact
        insert c;

        Test.startTest();

        c.Portal_Access__c = 'Activate';
        System.enqueueJob(new ContactPortalToggle(new List<Contact>{c}));

        Test.stopTest();
    }

    private static User createUser(Boolean userActive) {
        Account a = new Account(Name=EncodingUtil.convertToHex(Crypto.generateAesKey(128)));
        insert a;

        Contact c = new Contact(FirstName='Bob', LastName=EncodingUtil.convertToHex(Crypto.generateAesKey(128)), Email=EncodingUtil.convertToHex(Crypto.generateAesKey(128)) + '@c.org', AccountId=a.Id);
        insert c;

        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];

        User u = new User(
            IsActive=userActive,
            ContactId=c.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=c.Email,
            UserName=c.Email,
            Alias=c.Email.subString(0, 8),
            FirstName=c.FirstName,
            LastName=c.LastName
        );

        insert u;

        return u;

    }
}