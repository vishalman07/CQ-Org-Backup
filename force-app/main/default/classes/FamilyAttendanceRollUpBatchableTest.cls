/* 
 * 
 * @date          April 2023
 * @author        Minal Zaa
 * @description   Test class for FamilyAttendanceRollUpBatchable
 */
@IsTest
private class FamilyAttendanceRollUpBatchableTest {
    
    @IsTest
    static void testBatchJob() {
        List<SObject> lstAcc = TestDataFactory.createTestData('Account', 1); 
        insert lstAcc; 
        
        // start batch job
        Test.startTest();
        Database.executeBatch(new FamilyAttendanceRollUpBatchable(), 100);
        Test.stopTest();
        
        // assert that rollup was calculated for all accounts
        List<Account> updatedAccounts = [SELECT Id, Programs_Attended__c FROM Account WHERE Id IN :lstAcc];
        System.assertEquals(1, updatedAccounts.size()); 
    }
}