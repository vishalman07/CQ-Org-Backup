/**************************************************************************************************
* @Name         VolunteerNewsUpdateController
* @Author       Amit Yadav
* @Date         10/22/2023
* @Description  Apex class responsible for handling requests related to volunteer news and updates.
************************************************************************************************** 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         10/22/2023        Initial Creation                                                      
********************************************************************************************/
//Apex class responsible for handling requests related to volunteer news and updates.
public without sharing class VolunteerNewsUpdateController {
   
   //Retrieves page data from the Page for the volunteer portal and return Serialized JSON data containing information about volunteer news and updates.
   @AuraEnabled
    public static String getNewsAndUpdate(){
        String pageData = '';
         // Fetching the page details for volunteer news and updates.
        List<Page__c> pageList = [SELECT Id, Site__c, Name , Content__c , Page_URL_Name__c, Site__r.Name FROM Page__c WHERE Site__r.Name = 'Camp Quality Volunteers' AND Title__c = 'Volunteer News and Updates'];
        if(pageList.size() > 0){
            // Serializing the details to JSON.
            pageData = JSON.serialize(pageList[0]);
        }	
        return pageData;     
    }

	//Retrieves specific page data based on the provided site and page names and return Serialized JSON data containing information about the specified page.     
    @AuraEnabled
    public static String getPage(String site , String page){
        String pageData = '';
		// Fetching the page details based on the provided site and page names.
        List<Page__c> pageList = [SELECT Id , Content__c , Site__r.Site_URL__c , name FROM Page__c Where Site__r.Site_URL__c =:site AND name =:page];
    	if(pageList.size() > 0){
			// Serializing the page's details to JSON.
            pageData = JSON.serialize(pageList[0]);           
        }
        return pageData;
	}
}