/********************************************************************************************
* @Name         VolunteerResourcesController
* @Author       Amit Yadav
* @Date         10/22/2023
* @Description  Apex class responsible for handling requests related to volunteer resources
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         10/22/2023        Initial Creation                                                      
******************************************************************************************* */
//Apex class responsible for handling requests related to volunteer resources.
public without sharing class VolunteerResourcesController {
    
    //Retrieves volunteer resources data for the volunteer portal and return the Serialized JSON data containing information about online resources.
    @AuraEnabled
    public static String getResources(){
        // Fetching the site details associated with the required permission set.
        List<Site__c> siteList = [SELECT Name , Required_Permission_Set__c , Contact_Access_Field__c , Site_URL__c FROM Site__c WHERE Required_Permission_Set__c = 'Volunteer_Portal_Permissions' LIMIT 1];
        String data = '';
        if(siteList.size() > 0){
            // Fetching the page details for online resources based on the site.
            List<Page__c> pageList = [SELECT Content__c , Title__c , Site__c FROM Page__c WHERE Site__c = : siteList[0].Id AND Title__c = 'Online Resources'];
            // Serializing the first page's details to JSON.
            data = JSON.serialize(PageList[0]);
        }
        return data;
    }
}