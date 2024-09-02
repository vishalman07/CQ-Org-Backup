@isTest
public with sharing class FamilyAttendanceTest {

    
    @TestSetup
    static void makeData(){
        // Create a test family
        Account testFamily = new Account(Name='Test Family');
        insert testFamily;

        // Create a test student
        Contact testStudent = new Contact(LastName='Test Student', AccountId=testFamily.Id);
        insert testStudent;
 
        //create a campaign record for the event
        Campaign testCampaign = new Campaign(Name='Test Campaign', StartDate=Date.today(), EndDate=Date.today(), Type='Event');
        insert testCampaign;

        // Create a test family attendance record
        Family_Attendance__c testFamilyAttendance = new Family_Attendance__c(Family__c=testFamily.Id, Event__c=testCampaign.Id, Consent__c=true);
        testFamilyAttendance.FA_00000__c = 'Declined';
        insert testFamilyAttendance;
        
    }

    @isTest
    static void testFamilyAttendanceDelete() { 

        Family_Attendance__c testFamilyAttendance = [SELECT Consent__c, FA_00000__c FROM Family_Attendance__c ];

        // Test that the family attendance record was deleted
        delete testFamilyAttendance;
        System.assertEquals(0, [SELECT Id FROM Family_Attendance__c ].size());
    }

    @isTest
    static void testFamilyAttendanceUpdate() {  
        // Test that the family attendance record was updated
        Family_Attendance__c testFamilyAttendance = [SELECT Consent__c, FA_00000__c FROM Family_Attendance__c ];
        testFamilyAttendance.Consent__c = false;
        testFamilyAttendance.FA_00000__c = 'Attended';
        update testFamilyAttendance;

        System.assertEquals('Attended', [SELECT Consent__c, FA_00000__c FROM Family_Attendance__c ].FA_00000__c);

        
    }
}