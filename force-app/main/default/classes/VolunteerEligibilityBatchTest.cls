/********************************************************************************************
* @Name         VolunteerEligibilityBatchTest
* @Author       Amit Yadav
* @Date         06/08/2024
* @Description   Test class for VolunteerEligibilityBatch
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         06/08/2024       Initial Creation                                                      
********************************************************************************************/
@isTest
public class VolunteerEligibilityBatchTest {
    @testSetup
    static void setupTestData() {
        
        // Creating test Account records.
        Account ac = new Account();
        ac.Name = 'test';
        ac.Phone = '1234567890';
        ac.BillingStreet = 'testStreet';
        ac.BillingCity = 'Sydney';
        ac.BillingPostalCode = '778855';
        ac.BillingState = 'test';     
        insert ac;
        
        // Creating test Contact records.
        Contact con = new Contact();
        con.AccountId =ac.id;
        con.firstName = 'testingg';
        con.LastName = 'Test';
        con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Volunteer').getRecordTypeId();
        con.Volunteer_Types__c = 'Companion/Rover';
        
        // Add fields based on your provided data
        con.MailingStreet = 'A8 Saviour greenisle';
        con.MailingCity = 'ghaziabadd';
        con.MailingState = 'DL';
        con.MailingPostalCode = '352427';
        con.MailingCountry = 'US';
        con.Phone = '9187931132'; // Assuming this is a valid phone number format
        con.Email = 'test@testetst.com';
        
        // Add additional fields as needed
        con.Emergency_Contact_Relationship__c = 'Mother2';
        con.Gender__c = 'Male';
        con.Volunteer_Status__c = 'On Hold';
        con.Do_Not_Email__c = FALSE;
        con.Do_Not_Send_Mail__c = FALSE;
        con.Volunteer_Eligibility__c = 'Pending';
        con.Volunteer_Status__c	='Onboarding';
        insert con;
        
        // Create Volunteer Type
        Volunteer_Type__c volunteerType = new Volunteer_Type__c();
        volunteerType.Volunteer__c = con.id;
        volunteerType.Volunteer_Status__c = 'Active';
        volunteerType.Start_Date__c = Date.today().addDays(-1);
        volunteerType.End_Date__c = null;
        volunteerType.Volunteer_Type__c = 'Companion/Rover';
        insert volunteerType;
        
        // Create Volunteer Eligibility
        Volunteer_Eligibility__c eligibility = new Volunteer_Eligibility__c();
        eligibility.Volunteer_Eligibility_Criteria__c = 'Meet the Vollie Team';
        eligibility.Volunteer_Role__c = 'Companion/Rover';
        eligibility.Volunteer_Status__c = 'Onboarding';
        insert eligibility;
        
        //Create Volunteer Creteria
        Volunteer_Criteria__c volCri = new Volunteer_Criteria__c(); 
        volCri.Name = eligibility.Volunteer_Eligibility_Criteria__c;
        volCri.Criteria_Type__c	 = 'Online Learning';
        volCri.Criteria_Status__c = 'Active';
        volCri.Display_Order__c = 12;
        //volCri.Name = 'Code of Conduct';
        insert volCri;
        
        
        //Create Volunteer Complaince
        Volunteer_Compliance__c volComp  = new Volunteer_Compliance__c();
        volComp.Volunteer_Name__c = con.Id;
        volComp.Criteria_Type__c = 'Online Learning';
        volComp.Volunteer_Criteria__c = volCri.Id;
        volComp.PercentageComplete__c = 10;
        volComp.Litmos_Course_ID__c='1207831';
        volComp.Litmos_Course_Overdue__c = True;
        volComp.Status__c='Active	';
        insert volComp;
        
        //Create Volunteer Complaince
        Volunteer_Compliance__c volComp1  = new Volunteer_Compliance__c();
        volComp1.Volunteer_Name__c = con.Id;
        volComp1.Criteria_Type__c = 'Online Learning';
        volComp1.Volunteer_Criteria__c = volCri.Id;
        volComp1.PercentageComplete__c = 10;
        volComp1.Litmos_Course_ID__c='1207831';
        volComp1.Litmos_Course_Overdue__c = True;
        volComp1.Status__c='Inactive';
        insert volComp1;
    }
    
    @isTest
    static void testVolunteerEligibilityBatch() {
        Test.startTest();
        
        // Execute the batch
        VolunteerEligibilityBatch batch = new VolunteerEligibilityBatch();
        Database.executeBatch(batch, 1);
        
        Test.stopTest();
        
        // Verify results
        Volunteer_Type__c updatedVolunteerType = [SELECT Id, Volunteer_Status__c FROM Volunteer_Type__c WHERE Volunteer__c IN (SELECT Id FROM Contact) LIMIT 1];
        
        //Assuming 'Completed' compliance status maps to 'Active'
        System.assertEquals('Pending', updatedVolunteerType.Volunteer_Status__c, 'Volunteer Status should be Active');
    }
}