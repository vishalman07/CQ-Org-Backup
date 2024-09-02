/********************************************************************************************
* @Name         FamilyResourcePageController
* @Author       Amit Yadav
* @Date         10/22/2023
* @Description  This apex class is responsible for handling family resource page-related functionalities. 
				It provides methods to retrieve family resources based on certain criteria.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         11/22/2023        Initial Creation                                                      
******************************************************************************************* */
//This apex class is responsible for handling family resource page-related functionalities. It provides methods to retrieve family resources based on certain criteria.
public without sharing class FamilyResourcePageController {
	
    @AuraEnabled
    public static String getFamilyResources(){
        // Query the Site__c object to retrieve site information
		List<Site__c> siteList = [Select Name , Required_Permission_Set__c , Contact_Access_Field__c , Site_URL__c From Site__c Where Required_Permission_Set__c = 'Family_Portal_Permissions' Limit 1];
        String data = '';
		if(siteList.size() > 0){
            List<Page__c> pageList = [Select Content__c , Title__c , Site__c From Page__c Where Site__c = : siteList[0].Id AND Title__c = 'Resources'];
             data = JSON.serialize(PageList[0]);
        }
        //Return the JSON string containing family resource data
        return data;
	}
}