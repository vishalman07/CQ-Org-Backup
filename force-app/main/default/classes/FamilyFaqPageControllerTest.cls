@istest
public class FamilyFaqPageControllerTest {
    
    @testSetup
    public static void testSetup(){
        
        Site__c si = new Site__c();
        si.Name = 'TestSite';
        si.Required_Permission_Set__c = 'Family_Portal_Permissions';
        si.Contact_Access_Field__c = 'testContact';
        si.Site_URL__c = 'TestSiteURL';
        //si.Default_Page__c = pg.Id;
        insert si;

    }
    
    @isTest
    public static void testPotalData(){
        List<Site__c> si = [Select id,Name From site__c Where Name like 'Test%' Limit 1];  
        Page__c pg = new Page__c();
        pg.Content__c = 'text contect on a page';
        pg.Title__c = 'Frequently Asked Questions';
        pg.Site__c = si[0].Id;
        insert pg;
        Test.startTest();
        String famData = FamilyFaqPageController.getFaqData();

		Page__c expectedPage = [SELECT Id, Content__c, Title__c, Site__c FROM Page__c
                                WHERE Site__c = :si[0].Id AND Title__c = 'Frequently Asked Questions' LIMIT 1];
        String expectedData = JSON.serialize(expectedPage);

        System.assertEquals(expectedData, famData, 'Returned data should match expected data');
       
        Test.stopTest();
    }

}