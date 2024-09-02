/********************************************************************************************
* @Name         UpdateCampaignBatchTest
* @Author       Amit Yadav
* @Date         07/21/2023
* @Description  This test class cover the UpdateCampaignBatch class   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*--------------------------------------------------------------------------------------------
*  1.0             Amit Yadav         07/21/2023         Initial Creation                                                      
******************************************************************************************* */
@isTest
private class UpdateCampaignBatchTest {
    @TestSetup
    static void testSetup(){
        // Create test data
        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            md_npsp_pack__Platform_Key__c = 'TestPlatformKey'
        );
        insert testCampaign;
    }
    
    @IsTest 
    static void testUpdateCampaignBatch() {
        // Start the batch process
        Test.startTest();
        UpdateCampaignBatch updateBatch = new UpdateCampaignBatch();
        Id batchInstanceId = Database.executeBatch(updateBatch);
        Assert.isNotNull(batchInstanceId, 'batchInstanceId should not be null');
        Test.stopTest();

   }
}