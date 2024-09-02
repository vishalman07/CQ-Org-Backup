/********************************************************************************************
* @Name         VolunteerResourcesControllerTest
* @Author       Amit Yadav
* @Date         12/01/2023
* @Description  VolunteerResourcesControllerTest class contains test methods to validate 
				the behavior of methods in the VolunteerResourcesController class. 
				It focuses on testing various functionalities and cover positive negative senario.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/01/2023        Initial Creation                                                      
******************************************************************************************* */
@isTest
public class VolunteerResourcesControllerTest {
    
    @testSetup
    public static void testData(){
        // Creating a test Site data  
        Site__c si = new Site__c();
        si.Name = 'testSite';
        si.Required_Permission_Set__c = 'Volunteer_Portal_Permissions';
        si.Contact_Access_Field__c = 'testContactAccess';
        si.Site_URL__c = 'siteUrl';
        insert si;
        // Creating a test Page data  
        Page__c pg = new Page__c();
        pg.Content__c = 'text contenct on a page';
        pg.Title__c = 'Online Resources';
        pg.Site__c = si.Id;
        insert pg;
    }
    
    @isTest
    public static void testcheckResource(){
        
        Test.startTest();
        // Calling the getResources method.
        String resources = VolunteerResourcesController.getResources();       
        // Assuming getResources should return a non-null list
        System.assertNotEquals(null, resources, 'Resource list should not be null');
        Test.stopTest();
            
    }

}