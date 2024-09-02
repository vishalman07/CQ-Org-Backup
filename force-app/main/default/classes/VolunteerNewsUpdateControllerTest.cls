/**************************************************************************************************
* @Name         VolunteerNewsUpdateControllerTest
* @Author       Amit Yadav
* @Date         12/01/2023
* @Description  VolunteerNewsUpdateControllerTest class contains test methods to validate 
				the behavior of methods in the VolunteerNewsUpdateControllerTest class. 
				It focuses on testing various functionalities and cover different senario.
************************************************************************************************** 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/01/2023        Initial Creation                                                      
********************************************************************************************/
/*VolunteerNewsUpdateControllerTest class contains test methods to validate the behavior of methods in the VolunteerNewsUpdateControllerTest class. 
  It focuses on testing various functionalities and cover different senario.*/
@isTest
public class VolunteerNewsUpdateControllerTest {
    
    @testSetup
    public static void testData(){
        // Creating a test Site data
        Site__c si = new Site__c();
        si.Name = 'Camp Quality Volunteers';
        si.Required_Permission_Set__c = 'Volunteer_Portal_Permissions';
        si.Contact_Access_Field__c = 'testContactAccess';
        si.Site_URL__c = 'siteUrl';
        insert si;
        // Creating a test Page data 
        Page__c pg = new Page__c();
        pg.Content__c = 'text contenct on a page';
        pg.Title__c = 'Volunteer News and Updates';
        pg.Site__c = si.Id;
        pg.Name = 'testPageName';
        insert pg;       
    }
    
    @isTest
    public static void testgetNewsAndUpdate(){
        // Retrieving the Site and Page created in the test data setup.
        Site__c si = [SELECT Id, Name, Required_Permission_Set__c, Contact_Access_Field__c, Site_URL__c FROM Site__c WHERE Name = 'Camp Quality Volunteers'][0];
        Page__c pg = [SELECT Id, Content__c, Title__c, Site__c, Name FROM Page__c WHERE Title__c = 'Volunteer News and Updates'][0];
        // Start the test execution context
        Test.StartTest();
         // Calling the getNewsAndUpdate method to get the result string.
        String result = VolunteerNewsUpdateController.getNewsAndUpdate();
        // Assuming getNewsAndUpdate should return a non-null string.
        System.assertNotEquals(null, result, 'Result should not be null');
        // Calling the getPage method to get the result string for a specific Site and Page.
        String resultPage = VolunteerNewsUpdateController.getPage(si.Id, pg.Id);
        // Assuming getPage should return a non-null string.
        System.assertNotEquals(null, resultPage, 'Result should not be null');
        // Start the test execution context
        Test.StopTest();        
    }  
}