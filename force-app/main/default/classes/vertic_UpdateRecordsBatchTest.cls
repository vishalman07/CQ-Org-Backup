@IsTest
private class vertic_UpdateRecordsBatchTest {
    static testMethod void testBehavior() {

        Map<String, RecordType> rMap = new Map<String, RecordType>();
        for(RecordType r : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account']){
            rMap.put(r.DeveloperName, r);
        }
            
        Account a = New Account( Name = 'Family', RecordTypeId = rMap.get('Family').Id, Family_Type__c = 'Patient',Regionv2__c='ACT - Albury', Preferred_Event_Locations__c='Sydney', Family_Interests__c = 'Sports');
        insert a;

        Contact contactVar = new Contact(
            FirstName = 'test',
            LastName = 'test',
            Email = 'test@test.com',
            AccountId = a.Id
        );
        insert contactVar;

        Test.startTest();

        Database.executeBatch(new vertic_UpdateRecordsBatch(
            Contact.SObjectType,
            'FirstName = \'test\''
        ));

        Test.stopTest();
    }
}