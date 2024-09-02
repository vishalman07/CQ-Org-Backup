@isTest
private class ProcessLeadMappingTest {
    public static testMethod void testProcess() {
        Lead l = createTestData();

        Test.startTest();
        
        String ret = ProcessLeadMapping.ProcessLead(l.Id);
        
        System.debug(LoggingLevel.DEBUG, ret);

        Test.stopTest();
    }

    public static testMethod void testReferenceBatchContext() {
        Lead l = createTestData();

        Test.startTest();

        LeadMappingDataBatch lmdb = new LeadMappingDataBatch(l.Id);
        lmdb.processRecords(Database.query(lmdb.query));

        Database.executeBatch(new LeadMappingRefBatch(lmdb.theLead, lmdb.theLead.Mapping_Definition_Name__c, lmdb.objMap), 200);

        Test.stopTest();
    }
    
    public static testMethod void testButtonController() {
        
        Lead l = new Lead(FirstName='John', LastName='Doe', Email='john@doe.org', Company='Test Account', LeadSource='Advertisement', Status='New', Mapping_Definition_Name__c='Test Def');
        insert l;
        
        Mapping_Object__c conMap = new Mapping_Object__c(
            Definition__c=l.Mapping_Definition_Name__c,
            Object_API_Name__c='Contact'
        );
        
        Mapping_Object__c accMap = new Mapping_Object__c(
        	Definition__c=l.Mapping_Definition_Name__c,
            Object_API_Name__c='Account'
        );

        Mapping_Object__c campMap = new Mapping_Object__c(
        	Definition__c=l.Mapping_Definition_Name__c,
        	Object_API_Name__c = 'Campaign'
        );
        
        insert new List<Mapping_Object__c>{conMap, accMap, campMap};
        
        Mapping_Field__c conFirstName = new Mapping_Field__c(
        	Mapping_Object__c = conMap.Id,
            Field_API_Name__c = 'FirstName',
            Source_Fields__c = 'FirstName'
        );
        
        Mapping_Field__c conLastName = new Mapping_Field__c(
        	Mapping_Object__c = conMap.Id,
            Field_API_Name__c = 'LastName',
            Source_Fields__c = 'LastName'
        );
        
        Mapping_Field__c conEmail = new Mapping_Field__c(
        	Mapping_Object__c = conMap.Id,
            Field_API_Name__c = 'Email',
            Source_Fields__c = 'Email'
        );

        Mapping_Field__c accName = new Mapping_Field__c(
        	Mapping_Object__c = accMap.Id,
            Field_API_Name__c = 'Name',
            Source_Fields__c = 'Company'
        );
        
        Mapping_Field__c accCompoundFld = new Mapping_Field__c(
        	Mapping_Object__c = accMap.Id,
            Field_API_Name__c = 'Description',
            Source_Fields__c = 'Status+ +LeadSource'
        );

        Mapping_Field__c campName = new Mapping_Field__c(
        	Mapping_Object__c = campMap.Id,
        	Field_API_Name__c = 'Name',
        	Source_Fields__c = 'Company+ + - Campaign'
        );
        
		Mapping_Field__c campStart = new Mapping_Field__c(
        	Mapping_Object__c = campMap.Id,
            Field_API_Name__c = 'StartDate',
            Default_Value__c = '01/01/2016 15:55'
        );

        Mapping_Field__c campEnd = new Mapping_Field__c(
        	Mapping_Object__c = campMap.Id,
        	Field_API_Name__c = 'EndDate',
        	Default_Value__c = '12/12/2016 17:33'
        );
        
        Mapping_Field__c campActive = new Mapping_Field__c(
        	Mapping_Object__c = campMap.Id,
            Field_API_Name__c = 'IsActive',
            Default_Value__c = 'Yes'
        );

        Mapping_Field__c campActCost = new Mapping_Field__c(
        	Mapping_Object__c = campMap.Id,
            Field_API_Name__c = 'ActualCost',
            Default_Value__c = '20000.00'
        );
        
        insert new List<Mapping_Field__c>{conFirstName, conLastName, conEmail, accName, accCompoundFld, campName, campStart, campEnd, campActive, campActCost};
        
            
        Mapping_Reference__c accCon = new Mapping_Reference__c(
        	Mapping_Object__c = conMap.Id,
            Reference_Field_API_Name__c = 'AccountId',
            Reference_Type__c = 'SObject Definition',
            Defined_Object__c = accMap.Id
        );
        
        Mapping_Reference__c conOwn = new Mapping_Reference__c(
        	Mapping_Object__c = conMap.Id,
            Reference_Field_API_Name__c = 'OwnerId',
            Reference_Type__c = 'Id Value',
            Id_ExtId_Value__c = UserInfo.getUserId()
        );

        Mapping_Reference__c campMemb = new Mapping_Reference__c(
        	Mapping_Object__c = conMap.Id,
        	Reference_Type__c = 'Join Object',
        	Referenced_Object_API_Name__c = 'CampaignMember',
        	Reference_Field_API_Name__c = 'ContactId',
        	Defined_Object__c = campMap.Id,
        	Referenced_Object_ExtId_API_Name__c = 'CampaignId'
        );
        
        insert new List<Mapping_Reference__c>{accCon, conOwn, campMemb}; //, conReporter};
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        ProcessLeadMappingController plmc = new ProcessLeadMappingController(sc);
        
        plmc.processLeadMapping();
        
        Test.stopTest();
        
    }

    private static Lead createTestData() {
        Lead l = new Lead(FirstName='John', LastName='Doe', Email='john@doe.org', Company='Test Account', LeadSource='Advertisement', Status='New', Mapping_Definition_Name__c='Test Def');
        insert l;

        Mapping_Object__c conMap = new Mapping_Object__c(
            Definition__c=l.Mapping_Definition_Name__c,
            Object_API_Name__c='Contact'
        );
        
        Mapping_Object__c accMap = new Mapping_Object__c(
            Definition__c=l.Mapping_Definition_Name__c,
            Object_API_Name__c='Account'
        );

        Mapping_Object__c campMap = new Mapping_Object__c(
            Definition__c=l.Mapping_Definition_Name__c,
            Object_API_Name__c = 'Campaign'
        );
        
        insert new List<Mapping_Object__c>{conMap, accMap, campMap};
        
        Mapping_Field__c conFirstName = new Mapping_Field__c(
            Mapping_Object__c = conMap.Id,
            Field_API_Name__c = 'FirstName',
            Source_Fields__c = 'FirstName'
        );
        
        Mapping_Field__c conLastName = new Mapping_Field__c(
            Mapping_Object__c = conMap.Id,
            Field_API_Name__c = 'LastName',
            Source_Fields__c = 'LastName'
        );
        
        Mapping_Field__c conEmail = new Mapping_Field__c(
            Mapping_Object__c = conMap.Id,
            Field_API_Name__c = 'Email',
            Source_Fields__c = 'Email'
        );

        Mapping_Field__c accName = new Mapping_Field__c(
            Mapping_Object__c = accMap.Id,
            Field_API_Name__c = 'Name',
            Source_Fields__c = 'Company'
        );

        List<RecordType> rTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND isActive = true AND DeveloperName != 'HH_Account'];
        
        if(rTypes != null && rTypes.size() > 0) {
            Mapping_Field__c accRecordType = new Mapping_Field__c(
                Mapping_Object__c = accMap.Id,
                Field_API_Name__c = 'RecordTypeId',
                Default_Value__c = rTypes[0].Id
            );
        }
        
        Mapping_Field__c accCompoundFld = new Mapping_Field__c(
            Mapping_Object__c = accMap.Id,
            Field_API_Name__c = 'Description',
            Source_Fields__c = 'Status+ +LeadSource'
        );

        Mapping_Field__c campName = new Mapping_Field__c(
            Mapping_Object__c = campMap.Id,
            Field_API_Name__c = 'Name',
            Source_Fields__c = 'Company+ + - Campaign'
        );
        
        Mapping_Field__c campStart = new Mapping_Field__c(
            Mapping_Object__c = campMap.Id,
            Field_API_Name__c = 'StartDate',
            Default_Value__c = '01/01/2016 15:55'
        );

        Mapping_Field__c campEnd = new Mapping_Field__c(
            Mapping_Object__c = campMap.Id,
            Field_API_Name__c = 'EndDate',
            Default_Value__c = '12/12/2016 17:33'
        );
        
        Mapping_Field__c campActive = new Mapping_Field__c(
            Mapping_Object__c = campMap.Id,
            Field_API_Name__c = 'IsActive',
            Default_Value__c = 'Yes'
        );

        Mapping_Field__c campActCost = new Mapping_Field__c(
            Mapping_Object__c = campMap.Id,
            Field_API_Name__c = 'ActualCost',
            Default_Value__c = '20000.00'
        );
        
        insert new List<Mapping_Field__c>{conFirstName, conLastName, conEmail, accName, accCompoundFld, campName, campStart, campEnd, campActive, campActCost};
        
            
        Mapping_Reference__c accCon = new Mapping_Reference__c(
            Mapping_Object__c = conMap.Id,
            Reference_Field_API_Name__c = 'AccountId',
            Reference_Type__c = 'SObject Definition',
            Defined_Object__c = accMap.Id
        );
        
        Mapping_Reference__c conOwn = new Mapping_Reference__c(
            Mapping_Object__c = conMap.Id,
            Reference_Field_API_Name__c = 'OwnerId',
            Reference_Type__c = 'Id Value',
            Id_ExtId_Value__c = UserInfo.getUserId()
        );

        Mapping_Reference__c campMemb = new Mapping_Reference__c(
            Mapping_Object__c = conMap.Id,
            Reference_Type__c = 'Join Object',
            Referenced_Object_API_Name__c = 'CampaignMember',
            Reference_Field_API_Name__c = 'ContactId',
            Defined_Object__c = campMap.Id,
            Referenced_Object_ExtId_API_Name__c = 'CampaignId',
            Upsert_Field_API_Name__c = 'Campaign_Member_External_ID__c'
        );
        
        insert new List<Mapping_Reference__c>{accCon, conOwn, campMemb}; //, conReporter};

        Mapping_Field__c campMembEmail = new Mapping_Field__c(
            Mapping_Reference__c = campMemb.Id,
            Source_Fields__c = 'Email',
            Field_API_Name__c = 'Email'
        );

        Mapping_Field__c campMembPart = new Mapping_Field__c(
            Mapping_Reference__c = campMemb.Id,
            Source_Fields__c = 'FirstName+LastName+Email+Static Text',
            Field_API_Name__c = 'Participation__c'
        );

        Mapping_Field__c campMembExtId = new Mapping_Field__c(
            Mapping_Reference__c = campMemb.Id,
            Default_Value__c = String.valueOf(accCon.Id) + String.valueOf(conOwn.Id),
            Field_API_Name__c = 'Campaign_Member_External_ID__c'
        );

        insert new List<Mapping_Field__c>{campMembEmail, campMembPart, campMembExtId};

        return l;
    }
    
}