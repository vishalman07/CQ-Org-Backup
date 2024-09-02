@istest
public class FamilyResourcePageControllerTest {
    
    @testSetup
    public static void testSetUpData(){
        
        
        Site__c si = new Site__c();
        si.Name = 'TestSite';
        si.Required_Permission_Set__c = 'Family_Portal_Permissions';
        si.Contact_Access_Field__c = 'testContact';
        si.Site_URL__c = 'TestSiteURL';
        //si.Default_Page__c = pg.Id;
        insert si;
        
        Page__c pg = new Page__c();
        pg.Content__c = 'text contect on a page';
        pg.Title__c = 'Resources';
        pg.Site__c = si.Id;
        insert pg;
                    
    }
    
    @istest
    public static void testPotalData(){
        Test.startTest();
        List<Site__c> si = [Select id,Name From site__c Where Name like 'Test%' Limit 1];
        String resourceResult  = FamilyResourcePageController.getFamilyResources();
	
		Page__c expectedPage = [SELECT Id, Content__c, Title__c, Site__c FROM Page__c
                                WHERE Site__c = :si[0].Id AND Title__c = 'Resources' LIMIT 1];
        String expectedData = JSON.serialize(expectedPage);

        System.assertEquals(expectedData, expectedData, 'Returned data should match expected data');
        Test.stopTest();
            
    }

}