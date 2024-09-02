/*******************************************************************************************
* @Name         UpdateCampaignBatch 
* @Author       Amit Yadav <amit@cloudsheer.com>
* @Date         07/21/2023
* @TestClass    UpdateCampaignBatchTest
* @Description  To copy MoveData fields values to newly Created Custom Field 
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Amit              07/21/2023         Initial Creation                                                      
*******************************************************************************************/
public class UpdateCampaignBatch implements Database.Batchable<sObject> {
    // Start method to get the initial set of records
    public Database.QueryLocator start(Database.BatchableContext BC) {
        /* Query Campaign which md_npsp_pack__Platform_Key__c is not NULL */
        return Database.getQueryLocator('SELECT Name, md_npsp_pack__Platform_Key__c, md_npsp_pack__Fundraising_Contact__c, md_npsp_pack__Fundraising_Account__c, Funraisin_Id__c, md_npsp_pack__Campaign_Code__c, md_npsp_pack__Campaign_URL__c, md_npsp_pack__Platform__c, Platform__c, Campaign_code__c, Campaign_URL__c  FROM Campaign WHERE md_npsp_pack__Platform_Key__c != NULL AND Funraisin_Id__c = NULL');

    }
    
    // Execute method to process each batch of records
    public void execute(Database.BatchableContext BC, List<Campaign> campList) {
        for(Campaign camp_obj : campList) {
            camp_obj.Funraisin_Id__c = camp_obj.md_npsp_pack__Platform_Key__c;
            camp_obj.Contact_Fundraising__c = camp_obj.md_npsp_pack__Fundraising_Contact__c;
            camp_obj.Account_Fundraiser__c = camp_obj.md_npsp_pack__Fundraising_Account__c;
            camp_obj.Platform__c = camp_obj.md_npsp_pack__Platform__c ;
            camp_obj.Campaign_code__c = camp_obj.md_npsp_pack__Campaign_Code__c ;
            camp_obj.Campaign_URL__c = camp_obj.md_npsp_pack__Campaign_URL__c ;
        }      
        try {
            // Use update - DML to update the Campaign Name
            update campList;
        } catch (Exception e) {
            System.debug(e);
        }
    }
    // Finish method after all batches are processed
    public void finish(Database.BatchableContext BC) {

    }
}