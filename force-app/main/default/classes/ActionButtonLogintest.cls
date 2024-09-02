/********************************************************************************************
* @Name         ActionButtonLogintest
* @Author       Amit Yadav
* @Date         10/16/2023
* @Description  This is a testclass is login proxy login into the portal i.e. without entering username 
				and OTP
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         04/27/2024         Initial Creation                                                      
******************************************************************************************* */
@istest
public class ActionButtonLogintest {
    
    // Method to set up test data
    @testSetup
    public static void createAllData(){
        // Creating test Account records.
        Account ac = new Account();
        ac.Name = 'test';
        ac.Phone = '1234567890'; 
        insert ac;
        // Creating test Contact records.
        Contact con = new Contact();
        con.AccountId = ac.Id;
        con.firstName = 'testingg';
        con.LastName = 'Test';
        con.Email = 'test121@2.com';
        insert con;
        
    }
    
    // Test method for contactRecord functionality
    @istest
    public static void testcontactRecord(){
        // Querying a contact record
        Contact con = [SELECT ID,LastName FROM CONTACT WHERE LastName = 'Test' LIMIT 1];
        // Testing the contactRecord method
        ActionButtonLogin.contactRecord(con.Id);
    }
    
    // Test method for findUser functionality
    @istest
    public static void testfindUser(){

        // Querying a profile
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        // Creating a new User with the details from the Contact and the queried Profile
        Contact con = [SELECT Id,FirstName,LastName,Email FROM CONTACT WHERE LastName = 'Test' LIMIT 1];
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            UserName=con.Email,
            Alias=con.Email.subString(0,4),
            FirstName=con.FirstName,
            LastName=con.LastName
        ); 
        insert us;
        
        // Querying a permission set
        PermissionSet ps = [SELECT Id, Name 
                            FROM PermissionSet 
                            WHERE Name = 'Volunteer_Portal_Permissions'];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);

        
        // Test execution
        Test.startTest();
        // Calling the findUser method
        ActionButtonLogin.PermissionSetWrapper result = ActionButtonLogin.findUser(us.ContactId);
        Test.stopTest();
        
        // Assertion
        System.assertNotEquals(null, result, 'Permission Set Wrapper should not be null');
    }
    
    // Test method for findUserfamily functionality
    @istest
    public static void testfindUserfamily(){
        // Querying a profile
        Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
        // Creating a new User with the details from the Contact and the queried Profile
        Contact con = [SELECT Id,FirstName,LastName,Email FROM CONTACT WHERE LastName = 'Test' LIMIT 1];
        User us = new User(
            ContactId=con.Id,
            ProfileId=CommunityProfile.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=con.Email,
            UserName=con.Email,
            Alias=con.Email.subString(0,4),
            FirstName=con.FirstName,
            LastName=con.LastName
        ); 
        insert us;
        
        // Querying a permission set
        PermissionSet ps = [SELECT Id, Name 
                            FROM PermissionSet 
                            WHERE Name = 'Family_Portal_Permissions'];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);

        
        // Test execution
        Test.startTest();
        // Calling the findUser method
        ActionButtonLogin.PermissionSetWrapper result = ActionButtonLogin.findUser(us.ContactId);
        Test.stopTest();
        
        // Assertion
        System.assertNotEquals(null, result, 'Permission Set Wrapper should not be null');
    }
}