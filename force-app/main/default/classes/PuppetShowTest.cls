@isTest

public class PuppetShowTest {

    static testMethod void testPuppetShowTrigs(){
  //Setup school, child and puppet show.
  //
  RecordType SchoolTypeID = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Account' AND Name = 'School' LIMIT 1];
  RecordType FamilyMemberTypeID = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Family Member' LIMIT 1];
  RecordType FamilyAccountTypeID = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Family' LIMIT 1];
		Account testFam = new Account (Name='TestFam', RecordTypeId =FamilyAccountTypeID.Id );
        insert testFam;
        Account testSchool = new Account (Name= 'TestSchool' ,BillingState='VIC', RecordTypeId = SchoolTypeID.Id);
      insert testSchool;
        //,,

      Contact testChild = new Contact(LastName='Test', FirstName='Child', Birthdate=Date.today(), RecordTypeId = FamilyMemberTypeID.Id,School__c  = testSchool.id,Accountid = testFam.Id);//,);
      insert testChild;
   //    Contact testChild = [SELECT ID,school__c FROM Contact where lastname = 'Test' LIMIT 1];
      PuppetShow__c testPuppet = new PuppetShow__c(Puppet_Show_Name__c = 'Puppet Test Show', Child_Requesting_Show__c= testChild.ID,show_date__c= date.today());
      insert testPuppet;


    // Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
    // System.assertEquals('CA', updatedAccount.billingState);
    //
      PuppetShow__c testPuppetResults = [SELECT  ID, Venue__C,Performance_group__C  from PuppetShow__c where  Id =  :testPuppet.Id];
             //Test that school is added to show.
      System.assertEquals (testSchool.id, testPuppetResults.Venue__C);
        system.assertEquals('VIC/TAS', testPuppetResults.Performance_Group__c);
        PSP_Show_Attendee__c testAttendees = [SELECT ID, Contact__c  from PSP_Show_Attendee__c where Puppet_Show__c =  :testPuppet.Id];
        system.assertEquals(testChild.Id, testAttendees.Contact__c);
        //Test Rollup.
        //
        Account testa = [SELECT ID,Puppet_Shows_12__c,Puppet_Shows_1_2__c,Puppet_Shows_2__c,Puppet_Show__c FROM ACCOUNT where id = :testFam.Id ];
        system.assertEquals(testa.Puppet_Show__c, date.today());
        system.assertEquals(testa.Puppet_Shows_12__c, 1);
        system.assertEquals(testa.Puppet_Shows_1_2__c, 0);
        system.assertEquals(testa.Puppet_Shows_2__c, 0);

		delete  testAttendees;
        testa = [SELECT ID,Puppet_Shows_12__c,Puppet_Shows_1_2__c,Puppet_Shows_2__c,Puppet_Show__c FROM ACCOUNT where id = :testFam.Id ];
         system.assertEquals(testa.Puppet_Show__c, null);
        system.assertEquals(testa.Puppet_Shows_12__c, 0);
        system.assertEquals(testa.Puppet_Shows_1_2__c, 0);
        system.assertEquals(testa.Puppet_Shows_2__c, 0);
                testPuppet = new PuppetShow__c(Puppet_Show_Name__c = 'Test Puppet Show 2', Child_Requesting_Show__c= testChild.ID,show_date__c= date.today().addMonths(-14));

      insert testPuppet;

     testPuppet = new PuppetShow__c(Puppet_Show_Name__c = 'Test Puppet Show 3', Child_Requesting_Show__c= testChild.ID,show_date__c= date.today().addMonths(-36));

      insert testPuppet;


        set<id> aset = new set<id>();
        aset.add(testa.id);
        campquality.puppetShowRollup(aSet);

    }


}