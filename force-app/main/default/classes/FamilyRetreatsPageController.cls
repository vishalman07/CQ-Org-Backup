/*****************************************************************************************************************************************************************************
* @Name         FamilyRetreatsPageController
* @Author       Amit Yadav
* @Date         10/22/2023
* @Description  This apex class manages the functionalities related to family retreats page. It provides methods to fetch and handle data related to family retreat properties.
*******************************************************************************************************************************************************************************  
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         11/22/2023        Initial Creation                                                      
****************************************************************************************************************************************************************************/
//This apex class manages the functionalities related to family retreats page. It provides methods to fetch and handle data related to family retreat properties.
public without sharing class FamilyRetreatsPageController {
    //Retrieves property data for family retreats based on the user ID and returning list of FetchRetreatDataWrap containing property information and associated blob data.
    @AuraEnabled
    public static List<FetchRetreatDataWrap> getPropData(String recUserId){
        
        String decryptedString = FamilyPortalLoginController.decryptedData(recUserId);
        List<FetchRetreatDataWrap> camWrapperList = new List<FetchRetreatDataWrap>();       
        List<User> us = [SELECT Id, ContactId from User where Id=:decryptedString];      
        Contact con  = [Select Id, AccountId from Contact WHERE Id =:us[0].ContactId];
        List<Property__c> propList = [SELECT Id, Length_of_stay__c, Guests__c, Address__c, State__c, Available_for_booking_portal__c, Portal_Description__c,Name, 
                                      (SELECT Id, Account__c, Contact__c, Check_In_Date__c, Check_Out_Date__c, Status__c FROM Retreat_Bookings__r) FROM Property__c 
                                      WHERE Available_for_booking_portal__c = true];
        
        Set<Id> setContentDoc = new Set<Id>();  
        Set<Id> setOfpropId = new Set<Id>();
        // Collecting IDs of properties eligible for booking
        for(Property__c pr : propList){
            setOfpropId.add(pr.Id);
        }
        List<FetchRetreatDataWrap> retreatList = new List<FetchRetreatDataWrap>();
         // Fetching content document links related to eligible properties
        List<ContentDocumentLink> conLink = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:setOfpropId];
          // Gathering content document IDs
        for(ContentDocumentLink cdl : conLink){
            setContentDoc.add(cdl.ContentDocumentId);
        }
        
        List<ContentVersion> conVer = [SELECT ID, VersionData, Title, FirstPublishLocationId from ContentVersion WHERE ContentDocumentId IN:setContentDoc];
        Map<Id,Set<String>> propIdToBlob = new Map<Id,Set<String>>();
         // Creating a mapping between property IDs and associated blob data
        for(ContentVersion coVer : conVer){
            if(coVer.Title.contains('cq_portal_')){
                if(!propIdToBlob.containsKey(coVer.FirstPublishLocationId)){
                    propIdToBlob.put(coVer.FirstPublishLocationId, new Set<String>());  
                }
                propIdToBlob.get(coVer.FirstPublishLocationId).add(coVer.Id);
            }
        }
        for(Property__c prop : propList){
            FetchRetreatDataWrap fetctRetreat = new FetchRetreatDataWrap();
            fetctRetreat.propList = prop;
            fetctRetreat.blobData = propIdToBlob.get(prop.Id);
            retreatList.add(fetctRetreat);
            
        }          
        return retreatList;            
    }
    
    //Retrieves content version data for a given content version ID and it return hte base64 encoded version data of the content.
    @AuraEnabled
    public static String contentVersion(String contentVerId){
        List<ContentVersion> conVer = [SELECT ID, VersionData, FirstPublishLocationId from ContentVersion WHERE Id =:contentVerId];        
        return EncodingUtil.base64Encode(conVer[0].versionData);
    }
    
    // Wrapper class to hold property information and associated blob data.
    public class FetchRetreatDataWrap{
        @AuraEnabled public Property__c propList {get;set;}    
        @AuraEnabled public Set<String> blobData {get;set;}
    }      
}