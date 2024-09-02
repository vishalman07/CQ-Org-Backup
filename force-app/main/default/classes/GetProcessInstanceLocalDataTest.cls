/**
 * @Author  :   Minal Zaa 
 * @Date    :   Apr 7 2023
 * @Desc    :   Test class for GetProcessInstanceData - Coverage 97%
 */
@IsTest
public with sharing class GetProcessInstanceLocalDataTest {
    public GetProcessInstanceLocalDataTest() { }

    @isTest
    static void testGetProcessInstanceData() { 
        User approver = [SELECT Id FROM User WHERE IsActive = true AND UserRole.Name = 'System Administrator' LIMIT 1]; 

        // Create test data
        List<SObject> lstCamp = TestDataFactory.createTestData('Campaign', 1); 
        insert lstCamp; 
        List<SObject> lstAcc = TestDataFactory.createTestData('Account', 1); 
        insert lstAcc; 
        List<Account> lstAccount = [SELECT Id FROM Account];
        System.assertEquals(1, lstAccount.size(), 'Expected 1 Account records to be created'); 
        List<SObject> lstCon = TestDataFactory.createTestData('Contact', 1);
        for(SObject o : lstCon){
            o.put('AccountId', lstAccount[0].Id) ; 
        }
        insert lstCon;
        List<Contact> lstContact = [SELECT Id FROM Contact];
        System.assertEquals(1, lstContact.size(), 'Expected 1 Contact records to be created'); 

        List<SObject> lstReqToFundRaise = TestDataFactory.createTestData('Request_To_Fundraise__c', 1);
        for(SObject o : lstReqToFundRaise){
            o.put('ATF_Status__c', 'Request Approval') ;
            o.put('Contact__c', lstContact[0].Id); 
            o.put('Campaign__c', lstCamp[0].Id); 
            o.put('Approver__c', approver.id);
        }
        insert lstReqToFundRaise;
        
        

        // Create an approval process for Account
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setObjectId(lstReqToFundRaise[0].Id);
        submitRequest.setNextApproverIds(new List<Id>{approver.Id}); 

        // Test getProcessItemData
        String fieldNames = 'Name';
        String objectName = 'Request_To_Fundraise__c';
        String mode = 'View';
        String processItemData = GetProcessInstanceData.getProcessItemData(approver.Id, fieldNames, objectName, mode);
        System.assertNotEquals(null, processItemData, 'Process Item Data should not be null.');

        // Test process method
        List<String> workItemIds = new List<String>();
        for(ProcessInstanceWorkitem workitem : [SELECT Id FROM ProcessInstanceWorkitem WHERE ActorId = :approver.Id]) {
            workItemIds.add(workitem.Id);
        }

        Test.startTest();
        GetProcessInstanceData.process(null, 'Approve', workItemIds, 'Approved');
        Test.stopTest();

    }

    @isTest
    static void testProcessReassign() {
        List<User> users = [SELECT Id FROM User WHERE IsActive = true AND UserRole.Name = 'System Administrator' LIMIT 2]; 

        User approver = users[0];
        User reassignActor = users[1];

        // Create test data
        List<SObject> lstCamp = TestDataFactory.createTestData('Campaign', 1); 
        insert lstCamp; 
        List<SObject> lstAcc = TestDataFactory.createTestData('Account', 1); 
        insert lstAcc; 
        List<Account> lstAccount = [SELECT Id FROM Account];
        System.assertEquals(1, lstAccount.size(), 'Expected 1 Account records to be created'); 
        List<SObject> lstCon = TestDataFactory.createTestData('Contact', 1);
        for(SObject o : lstCon){
            o.put('AccountId', lstAccount[0].Id) ; 
        }
        insert lstCon;
        List<Contact> lstContact = [SELECT Id FROM Contact];
        System.assertEquals(1, lstContact.size(), 'Expected 1 Contact records to be created'); 

        List<SObject> lstReqToFundRaise = TestDataFactory.createTestData('Request_To_Fundraise__c', 1);
        for(SObject o : lstReqToFundRaise){
            o.put('ATF_Status__c', 'Request Approval') ;
            o.put('Contact__c', lstContact[0].Id); 
            o.put('Campaign__c', lstCamp[0].Id); 
            o.put('Approver__c', approver.id);
        }
        insert lstReqToFundRaise;

        

        // Create an approval process for Account
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setObjectId(lstReqToFundRaise[0].Id);
        submitRequest.setNextApproverIds(new List<Id>{approver.Id}); 

        // Test process method with 'Reassign' action
        List<String> workItemIds = new List<String>();
        for(ProcessInstanceWorkitem workitem : [SELECT Id FROM ProcessInstanceWorkitem WHERE ActorId = :approver.Id]) {
            workItemIds.add(workitem.Id);
        }

        Test.startTest();
        GetProcessInstanceData.process(reassignActor.Id, 'Reassign', workItemIds, 'Reassigning');
        Test.stopTest();

        ProcessInstanceWorkitem reassignedWorkitem = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE Id IN :workItemIds];
        System.assertEquals(reassignActor.Id, reassignedWorkitem.ActorId, 'The approval process should have been reassigned to the new actor.');
    }
}