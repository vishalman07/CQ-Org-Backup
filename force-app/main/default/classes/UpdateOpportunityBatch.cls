/*******************************************************************************************
* @Name         UpdateOpportunityBatch 
* @Author       Amit Yadav <amit@cloudsheer.com>
* @Date         07/21/2023
* @TestClass    UpdateOpportunityBatchTest
* @Description  To copy MoveData fields values to newly Created Custom Field 
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Amit              07/21/2023         Initial Creation                                                      
*******************************************************************************************/
public class UpdateOpportunityBatch implements Database.Batchable<sObject> {
    // Start method to provide the initial set of records for processing
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Name, md_npsp_pack__Platform_Key__c, md_npsp_pack__Platform_Fee_Tax__c, md_npsp_pack__Platform_Fee__c, md_npsp_pack__Tax__c, md_npsp_pack__Gateway_Fee_Tax__c, md_npsp_pack__Fee__c , md_npsp_pack__Gateway_Fee__c, Platform_Fee_Tax__c, Platform_Fee__c, Tax__c, Gateway_Fee_Tax__c, Fee__c, Gateway_Fee__c, Funraisin_Id__c FROM Opportunity WHERE md_npsp_pack__Platform_Key__c != NULL AND Funraisin_Id__c = NULL ');
    }
    // Execute method to process each batch of records
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        for (Opportunity opp_obj : oppList) {
            // Map the Platform Key value to the custom field Funraisin_Id__c
            opp_obj.Funraisin_Id__c = opp_obj.md_npsp_pack__Platform_Key__c;
            opp_obj.Platform_Fee_Tax__c = opp_obj.md_npsp_pack__Platform_Fee_Tax__c;
            opp_obj.Platform_Fee__c = opp_obj.md_npsp_pack__Platform_Fee__c;
            opp_obj.Tax__c = opp_obj.md_npsp_pack__Tax__c;
            opp_obj.Gateway_Fee_Tax__c = opp_obj.md_npsp_pack__Gateway_Fee_Tax__c;
            opp_obj.Fee__c = opp_obj.md_npsp_pack__Fee__c ;
            opp_obj.Gateway_Fee__c = opp_obj.md_npsp_pack__Gateway_Fee__c;

        }      
        try {
            // Use DML update to persist the changes
            update oppList;
        } catch (Exception e) {
            // Handle any exceptions and log them
            System.debug(e);
        }
    }
    // Finish method executed after all batches are processed
    public void finish(Database.BatchableContext BC) {
        // Any cleanup or post-processing tasks can be performed here
    }
}