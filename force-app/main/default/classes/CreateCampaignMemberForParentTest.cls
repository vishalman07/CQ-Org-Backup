/********************************************************************************************
* @Name         CreateCampaignMemberForParentTest
* @Author       Amit Yadav
* @Date         08/24/2023
* @Description  This test class cover the CreateCampaignMemberForParent class   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         08/24/2023         Initial Creation                                                      
******************************************************************************************* */
@isTest
public class CreateCampaignMemberForParentTest {
    
    @testSetup static void createRecord() {
        Id fundraisingRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        Id generalContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
        
      //  List<CampaignMember> campMemList = new List<CampaignMember>();
        // Create test Account record
        Account ac = new Account(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organisation').getRecordTypeId()
        );
        insert ac;
        // Create test Contact record
        Contact testContact = new Contact(
            AccountId = ac.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            RecordTypeId = generalContactRecordTypeId,
            Email = 'test@example.com'
        );
        insert testContact;
        // Create test Contact record
        Contact testContact2 = new Contact(
            AccountId = ac.Id,
            FirstName = 'Test2',
            LastName = 'Contact2',
            RecordTypeId = generalContactRecordTypeId,
            Email = 'test2@example.com'
        );
        insert testContact2;
        Contact testContact3 = new Contact(
            AccountId = ac.Id,
            FirstName = 'Test3',
            LastName = 'Contact3',
            RecordTypeId = generalContactRecordTypeId,
            Email = 'test3@example.com'
        );
        insert testContact3;
        // Create test Campaign record
        Campaign testCamp = new Campaign(
            Name = 'Test Camp',
            RecordTypeId = fundraisingRecordTypeId
        );
        insert testCamp;
        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            ParentId = testCamp.Id,
            RecordTypeId = fundraisingRecordTypeId
        );
        insert testCampaign;
      /*  CampaignMember campMem = new CampaignMember(CampaignId = testCampaign.Id, ContactId = testContact2.Id);
        campMemList.add(campMem); */
        // Create test Campaign records with parent-child relationships
        Campaign testCampaign1 = new Campaign(
            ParentId = testCampaign.Id,
            Name = 'Test Campaign1',
            RecordTypeId = fundraisingRecordTypeId
        );
        insert testCampaign1;
     /*   CampaignMember campMem1 = new CampaignMember(CampaignId = testCampaign1.Id, ContactId = testContact2.Id);
        campMemList.add(campMem1); */
        Campaign testCampaign2 = new Campaign(
            ParentId = testCampaign1.Id,
            Name = 'Test Campaign2',
            RecordTypeId = fundraisingRecordTypeId
        );
        insert testCampaign2;
    /*    CampaignMember campMem2 = new CampaignMember(CampaignId = testCampaign2.Id, ContactId = testContact2.Id);
        campMemList.add(campMem2); */
        Campaign testCampaign3 = new Campaign(
            ParentId = testCampaign2.Id,
            Name = 'Test Campaign3',
            RecordTypeId = fundraisingRecordTypeId
        );
        insert testCampaign3;
       /* CampaignMember campMem3 = new CampaignMember(CampaignId = testCampaign3.Id, ContactId = testContact2.Id);
        campMemList.add(campMem3);
        CampaignMember campMem4 = new CampaignMember(CampaignId = testCampaign3.Id, ContactId = testContact3.Id);
        campMemList.add(campMem4);
        insert campMemList; */
        Campaign testCampaign4 = new Campaign(
            ParentId = testCampaign2.Id,
            Name = 'Test Campaign4',
            RecordTypeId = fundraisingRecordTypeId
        );
        insert testCampaign4;
    }
    @isTest
    static void callingMethod() {
        List<CampaignMember> campMemList = new List<CampaignMember>();
        List<Campaign> campList = [Select Id , ParentId , Parent.ParentId , Parent.Parent.ParentId , Parent.Parent.Parent.ParentId , Name From Campaign Where Name = 'Test Campaign3'];
        List<Contact> con = [Select Id , LastName From Contact Where LastName = 'Contact2'];
        List<Contact> con3 = [Select Id , LastName From Contact Where LastName = 'Contact3'];
        
        CampaignMember campMem1 = new CampaignMember(CampaignId = campList[0].Parent.Parent.Parent.ParentId, ContactId = con[0].Id);
        campMemList.add(campMem1);
        CampaignMember campMemold = new CampaignMember(CampaignId = campList[0].Parent.Parent.ParentId, ContactId = con[0].Id);
        campMemList.add(campMemold);
        CampaignMember campMem = new CampaignMember(CampaignId = campList[0].Parent.ParentId, ContactId = con[0].Id);
        campMemList.add(campMem);
        CampaignMember campMem2 = new CampaignMember(CampaignId = campList[0].ParentId, ContactId = con[0].Id);
        campMemList.add(campMem2);
        CampaignMember campMem3 = new CampaignMember(CampaignId = campList[0].Id, ContactId = con[0].Id);
        campMemList.add(campMem3);
        CampaignMember campMem4 = new CampaignMember(CampaignId = campList[0].Id, ContactId = con3[0].Id);
        campMemList.add(campMem4);
        insert campMemList;
        List<Campaign> campaignList = [SELECT Id,  ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId FROM Campaign WHERE Name = 'Test Campaign4'];
        List<Contact> conList = [SELECT Id,LastName FROM Contact where FirstName ='Test']; 
        List<CampaignMember> campMemList1 = new List<CampaignMember>();
        // Create test CampaignMember record
        CampaignMember testCampaignMember = new CampaignMember(
            CampaignId = campaignList[0].Id,
            ContactId = conList[0].Id
        );
        campMemList1.add(testCampaignMember);
        Test.startTest();
        insert campMemList1;
        Test.stopTest();
		CreateCampaignMemberForParent.campaignMemberForParent(campMemList);
    }
    
    
    @isTest
    static void testCatchBlock() {
        Error_Log__c er = new Error_Log__c();
        er.Error_Message__c = 'Found Err';
        er.Generated_Error_Time__c = DateTime.now();
        er.Line_Number__c = 23;
        insert er;
        List<CampaignMember> campMemList = new List<CampaignMember>();
        List<Campaign> campList = [Select Id , ParentId , Parent.ParentId , Parent.Parent.ParentId , Parent.Parent.Parent.ParentId , Name From Campaign Where Name = 'Test Campaign3'];
        List<Contact> con = [Select Id , LastName From Contact Where LastName = 'Contact2'];
        List<Contact> con3 = [Select Id , LastName From Contact Where LastName = 'Contact3'];
        
        /*CampaignMember campMem1 = new CampaignMember(CampaignId = campList[0].Parent.Parent.Parent.ParentId, ContactId = con[0].Id);
        campMemList.add(campMem1);
        CampaignMember campMemold = new CampaignMember(CampaignId = campList[0].Parent.Parent.ParentId, ContactId = con[0].Id);
        campMemList.add(campMemold);
        CampaignMember campMem = new CampaignMember(CampaignId = campList[0].Parent.ParentId, ContactId = con[0].Id);
        campMemList.add(campMem);
        CampaignMember campMem2 = new CampaignMember(CampaignId = campList[0].Parent.ParentId, ContactId = con[0].Id);
        campMemList.add(campMem2);
        CampaignMember campMem3 = new CampaignMember(CampaignId = campList[0].Id, ContactId = con[0].Id);
        campMemList.add(campMem3);
        CampaignMember campMem4 = new CampaignMember(CampaignId = campList[0].Id, ContactId = con3[0].Id);
        campMemList.add(campMem4);
        insert campMemList;*/
        List<Campaign> campaignList = [SELECT Id  FROM Campaign WHERE Name = 'Test Campaign4' ];
        List<Contact> conList = [SELECT Id FROM Contact where FirstName ='Test3']; 
        List<CampaignMember> campMemList1 = new List<CampaignMember>();
        // Create test CampaignMember record
        CampaignMember testCampaignMember = new CampaignMember(
            CampaignId = campaignList[0].Id,
            ContactId = conList[0].Id
        );
        campMemList1.add(testCampaignMember);
        Test.startTest();
        insert campMemList1;
        Test.stopTest();
		CreateCampaignMemberForParent.campaignMemberForParent(campMemList);
    }

}