/*
 * Copyright  2023 Camp Quality, Author - Minal Zaa

 * @date          March 2023
 * @author        Minal Zaa
 * @email         zaa.minal@gmail.com 
 * @description   Apex class to contain utility methods needed for Test Classes
 */

public with sharing class TestClassUtil {
    public TestClassUtil() { }

    /**
     * Test classes needs unique user otehrwise it might fail during deployments.
     * Get unique StandardTestUser
     */ 
    public static User createStdPortalTestUser() {

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;

        Id pId = [select id from profile where name='My Camp Quality Members'].id;
       
        Account ac = new Account(name ='Test Account') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,npsp__Deceased__c= false, Exclude_From_Portal__c = false);
        insert con;  
                  
        User user = new User(alias = 'test123',  
                                email = uniqueName + '@campquality' + orgId + '.org',
                                Username = uniqueName + '@campquality' + orgId + '.org',
                                emailencodingkey='UTF-8', 
                                lastname='Testing', 
                                languagelocalekey='en_US',
                                localesidkey='en_US', 
                                profileid = pId, 
                                country='United States',
                                IsActive =true,
                                ContactId = con.Id, 
                                timezonesidkey='America/Los_Angeles' );
       
        insert user;

        return user;
 
    }
    
    public static User createStdTestUser() {

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;

        Id pId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].id;
            
        User user = new User(alias = 'test123',  
                                email = uniqueName + '@campquality' + orgId + '.org',
                                Username = uniqueName + '@campquality' + orgId + '.org',
                                emailencodingkey='UTF-8', 
                                lastname='Testing', 
                                languagelocalekey='en_US',
                                localesidkey='en_US', 
                                profileid = pId, 
                                country='United States',
                                IsActive =true,
                             
                                timezonesidkey='America/Los_Angeles' );
       
        insert user;

        return user;
 
    }
}