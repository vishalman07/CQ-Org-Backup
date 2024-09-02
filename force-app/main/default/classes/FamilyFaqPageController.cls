public without sharing class FamilyFaqPageController {
    
    @AuraEnabled 
    public static String getFaqData(){
        
        List<Site__c> siteList = [Select Name , Required_Permission_Set__c , Contact_Access_Field__c , 
                                  Site_URL__c From Site__c Where Required_Permission_Set__c = 'Family_Portal_Permissions' LIMIT 1];
        String data = '';
        if(siteList.size() > 0){
         	LIST<Page__c> pageData = [SELECT Id, Content__c , Title__c , Site__c 
                                      From Page__c Where Site__c = : siteList[0].Id AND Title__c = 'Frequently Asked Questions'];
            data = JSON.serialize(pageData[0]);
        }        
        return data;
    }

}