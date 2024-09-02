/********************************************************************************************
* @Name         CreateCampaignMemberForParent
* @Author       Amit Yadav
* @Date         08/24/2023
* @Description  This class create the campaign member on parent campaign when campaign member is created 
And this class use in "RTF-CAMPMEM01-CampaignMemberForParentCampaign" Flow.  
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         08/24/2023         Initial Creation                                                      
******************************************************************************************* */
public class CreateCampaignMemberForParent {
    // Invocable method to create Campaign Members for parent Campaigns
    @InvocableMethod(label='Create Campaign Members' description='Creates Campaign Members for parent Campaign')
    //public static void campaignMemberForParent(List<Id> campMemberIds) {
    public static void campaignMemberForParent(List<CampaignMember> campMembers) {
        // List to store new Campaign Members
        List<CampaignMember> campMemListToInsert = new List<CampaignMember>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, List<CampaignMember>> campaignIdAndMemMap = new Map<Id, List<CampaignMember>>();
        //for(CampaignMember campMem: campaignMemList){
        for(CampaignMember campMem: campMembers){
            contactIds.add(campMem.ContactId);
            if (!campaignIdAndMemMap.containsKey(campMem.campaignId)) {
                campaignIdAndMemMap.put(campMem.campaignId, new List<CampaignMember>());
            }
            campaignIdAndMemMap.get(campMem.campaignId).add(campMem);
        }
        List<Campaign> campList = new List<Campaign>();
        // Fetch the parent and ancestor Campaign records
        if(campaignIdAndMemMap != null){
            campList = [SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId FROM Campaign WHERE Id = :campaignIdAndMemMap.keySet()];
        }
        Set<Id> parentCampaignIds = new Set<Id>();
        for(Campaign camp : campList){
            if(camp.ParentId != null){
                parentCampaignIds.add(camp.ParentId);
            }
            if(camp.ParentId != null && camp.Parent.ParentId != null){
                parentCampaignIds.add(camp.Parent.ParentId);
                 system.debug(' parentCampaignIds---1'+ parentCampaignIds);
            }
            if(camp.ParentId != null && camp.Parent.ParentId != null &&  camp.Parent.Parent.ParentId != null){
                parentCampaignIds.add(camp.Parent.Parent.ParentId);
                 system.debug(' parentCampaignIds---2'+ parentCampaignIds);
            }
            if(camp.ParentId != null && camp.Parent.ParentId != null &&  camp.Parent.Parent.ParentId != null && camp.Parent.Parent.Parent.ParentId != null){
                parentCampaignIds.add(camp.Parent.Parent.Parent.ParentId);
                system.debug(' parentCampaignIds---3'+ parentCampaignIds);
            }
        }
        List<campaignMember> campMemAndConList = new List<campaignMember>();
        if(parentCampaignIds.size() > 0 && contactIds.size() > 0){
            campMemAndConList = [Select Id, ContactId, CampaignId From CampaignMember Where ContactId In :contactIds AND CampaignId IN :parentCampaignIds];
        }
        Map<Id, Set<Id>> campConIdMap = new Map<Id, Set<Id>>();
        if(campMemAndConList.size() > 0){
            system.debug('campMemAndConList--'+campMemAndConList);
            for(campaignMember campMem : campMemAndConList){
                if(!campConIdMap.containsKey(campMem.CampaignId)){
                    campConIdMap.put(campMem.CampaignId, new Set<Id>());
                }
                campConIdMap.get(campMem.CampaignId).add(campMem.ContactId);
            }
        }
        if(campList.size() > 0 ){
            // Check if the Campaign has a Parent, and if so, create Campaign Members for its ancestors
            for(campaign camp : campList){
                //if (campaignIdAndMemMap.containsKey(camp.Id)) {
                for(CampaignMember campMemInner : campaignIdAndMemMap.get(camp.Id)){
                    if (camp.ParentId != null && !campConIdMap.containsKey(camp.ParentId)) {
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = camp.ParentId;
                        campMem.ContactId = campMemInner.ContactId;
                        campMemListToInsert.add(campMem);
                        system.debug('campMemListToInsert---1'+campMemListToInsert);
                    }else if(camp.ParentId != null && campConIdMap.containsKey(camp.ParentId) && !campConIdMap.get(camp.ParentId).contains(campMemInner.ContactId)){
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = camp.ParentId;
                        campMem.ContactId = campMemInner.ContactId;
                        campMemListToInsert.add(campMem);
                        system.debug('campMemListToInsert---2'+campMemListToInsert);
                    }
                    if (camp.Parent.ParentId != null && !campConIdMap.containsKey(camp.Parent.ParentId)) {
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = camp.Parent.ParentId;
                        campMem.ContactId = campMemInner.ContactId;
                        campMemListToInsert.add(campMem);
                        system.debug('campMemListToInsert---3'+campMemListToInsert);
                    }else if(camp.Parent.ParentId != null && campConIdMap.containsKey(camp.Parent.ParentId) && !campConIdMap.get(camp.Parent.ParentId).contains(campMemInner.ContactId)){
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = camp.Parent.ParentId;
                        campMem.ContactId = campMemInner.ContactId;
                        campMemListToInsert.add(campMem);
                        system.debug('campMemListToInsert---4'+campMemListToInsert);
                    }
                    if (camp.Parent.Parent.ParentId != null && !campConIdMap.containsKey(camp.Parent.Parent.ParentId)) {
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = camp.Parent.Parent.ParentId;
                        campMem.ContactId = campMemInner.ContactId;
                        campMemListToInsert.add(campMem);
                        system.debug('campMemListToInsert---5'+campMemListToInsert);
                    }else if(camp.Parent.Parent.ParentId != null && campConIdMap.containsKey(camp.Parent.Parent.ParentId) && !campConIdMap.get(camp.Parent.Parent.ParentId).contains(campMemInner.ContactId)){
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = camp.Parent.Parent.ParentId;
                        campMem.ContactId = campMemInner.ContactId;
                        campMemListToInsert.add(campMem);
                        system.debug('campMemListToInsert---6'+campMemListToInsert);
                    }
                    if (camp.Parent.Parent.Parent.ParentId != null && !campConIdMap.containsKey(camp.Parent.Parent.Parent.ParentId)) {
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = camp.Parent.Parent.Parent.ParentId;
                        campMem.ContactId = campMemInner.ContactId;
                        campMemListToInsert.add(campMem);
                        system.debug('campMemListToInsert---7'+campMemListToInsert);
                    }else if(camp.Parent.Parent.Parent.ParentId != null && campConIdMap.containsKey(camp.Parent.Parent.Parent.ParentId) && !campConIdMap.get(camp.Parent.Parent.Parent.ParentId).contains(campMemInner.ContactId)){
                        CampaignMember campMem = new CampaignMember();
                        campMem.CampaignId = camp.Parent.Parent.Parent.ParentId;
                        campMem.ContactId = campMemInner.ContactId;
                        campMemListToInsert.add(campMem);
                    }
                }
            }
        }
        
        // Insert the new Campaign Members
        if (campMemListToInsert.size() > 0) {
            try {
                List<Error_Log__c> errLogList = new List<Error_Log__c>();
                
                Database.UpsertResult[] srList = Database.upsert(campMemListToInsert, false);
                // Iterate through each returned result
                for (Database.UpsertResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted. camMember ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('CamMember fields that affected this error: ' + err.getFields());    
                            Error_Log__c er = new Error_Log__c();
                            er.Error_Message__c = err.getMessage();
                            er.Generated_Error_Time__c = DateTime.now();
                            errLogList.add(er);
                        }
                        insert errLogList;
                    }
                }
                
            }catch(Exception e) {
                // Handle any general exceptions here
                System.debug('An exception occurred: ' + e.getMessage());
                Error_Log__c er = new Error_Log__c();
                er.Error_Message__c = e.getMessage();
                er.Generated_Error_Time__c = DateTime.now();
                er.Line_Number__c = e.getLineNumber();
                insert er;
            }
        }
    }
}