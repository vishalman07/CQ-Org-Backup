/********************************************************************************************
* @Name         UpdateOpportunityBatchTest
* @Author       Amit Yadav
* @Date         07/21/2023
* @Description  This test class cover the UpdateOpportunityBatch class   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         07/21/2023         Initial Creation                                                      
******************************************************************************************* */
@isTest
private class UpdateOpportunityBatchTest {
    @TestSetup
    static void testSetup(){
         // Create test data
         Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            md_npsp_pack__Platform_Key__c = 'TestPlatformKey',
            StageName = 'Closed Won',
            CloseDate = System.today()
        );
        insert testOpportunity;
    }
    @isTest static void testUpdateOpportunityBatch() {
        // Start the batch process
        Test.startTest();
        UpdateOpportunityBatch updateBatch = new UpdateOpportunityBatch();
        Id batchInstanceId = Database.executeBatch(updateBatch);
        Assert.isNotNull(batchInstanceId, 'batchInstanceId should not be null');
        Test.stopTest();
    }
}