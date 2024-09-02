public class LeadMappingDataBatch implements Database.Batchable<sObject>, Database.Stateful {
	class LeadMappingException extends Exception { }
	public static String MappingObjQuery = 'SELECT Id, Name, Definition__c, Object_API_Name__c, Upsert_Object_Field_API_Name__c, Process_Order__c, (SELECT Id, Field_API_Name__c, Source_Fields__c, Default_Value__c FROM Mapping_Fields__r) FROM	  Mapping_Object__c WHERE  Definition__c = ';

	@TestVisible
    String query;
	@TestVisible
    Lead theLead;
	@TestVisible
    Map<Id, SObject> objMap;

	public LeadMappingDataBatch(Id leadId) {
		String leadQuery = 'SELECT ';

		for (Schema.SObjectField fld : Schema.SObjectType.Lead.fields.getMap().values())
			leadQuery += fld.getDescribe().getName() + ',';
        
        leadQuery = leadQuery.subString(0, leadQuery.length() - 1);
        
        leadQuery += ' FROM Lead WHERE Id = \'' + leadId + '\' LIMIT 1';

		System.debug(LoggingLevel.DEBUG, 'LeadMappingDataBatch leadQuery: ' + leadQuery);

		this.theLead = (Lead)Database.query(leadQuery);
        
        String definitionName = theLead.Mapping_Definition_Name__c;

        if (String.isBlank(definitionName))
        	throw new LeadMappingException('Lead has no Mapping Definition Name');
        else if (theLead.Lead_Mapping_Processed__c)
        	throw new LeadMappingException('Lead Mapping has already been processed for this record');

        this.query = MappingObjQuery + ' \'' + definitionName + '\' ORDER BY Process_Order__c';

        this.objMap = new Map<Id, SObject>();
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
	   this.processRecords(scope);
    }

    @TestVisible
    private void processRecords(List<SObject> scope) {
    	Map<String, Schema.SObjectType> allSObjTypes = Schema.getGlobalDescribe();
		Map<String, Map<String, Schema.SObjectField>> sobjFldMaps = new Map<String, Map<String, Schema.SObjectField>>{
	        'Lead' =>  Schema.SObjectType.Lead.fields.getMap()   
	    };

	    Map<String, Schema.SObjectField> leadFlds = sobjFldMaps.get('Lead');

	    for (SObject sobj : scope) {
	    	Mapping_Object__c mapObj = (Mapping_Object__c)sobj;

	    	if (allSObjTypes.containsKey(mapObj.Object_API_Name__c)) {
                SObject thisObj = allSObjTypes.get(mapObj.Object_API_Name__c).newSObject();
                
                if (!sobjFldMaps.containsKey(mapObj.Object_API_Name__c))
                    sobjFldMaps.put(mapObj.Object_API_Name__c, allSObjTypes.get(mapObj.Object_API_Name__c).getDescribe().fields.getMap());
                
                Map<String, Schema.SObjectField> thisObjFlds = sobjFldMaps.get(mapObj.Object_API_Name__c);
                // process data fields here..
                for (Mapping_Field__c mapFld : mapObj.Mapping_Fields__r) {
                    if (thisObjFlds.containsKey(mapFld.Field_API_Name__c)) {
                        String sourceValue = '';
                        
                        if (!String.isBlank(mapFld.Source_Fields__c)) {
                            if (mapFld.Source_Fields__c.contains('+')) {
                                for (String srcFld : mapFld.Source_Fields__c.split('\\+')) {
                                    if (leadFlds.containsKey(srcFld)) {
                                        if (theLead.get(srcFld) != null)
                                            sourceValue += String.valueOf(theLead.get(srcFld));
                                    } else {
                                        sourceValue += srcFld;
                                    }
                                }
                            } else if (leadFlds.containsKey(mapFld.Source_Fields__c)) {
                                sourceValue = String.valueOf(theLead.get(mapFld.Source_Fields__c));
                            }
                        }
                        
                        if (String.isBlank(sourceValue) && !String.isBlank(mapFld.Default_Value__c))
                            sourceValue = mapFld.Default_Value__c;
                        
                        if (String.isBlank(sourceValue))
                            sourceValue = null;
                        
                        ProcessLeadMapping.data(thisObj, thisObjFlds.get(mapFld.Field_API_Name__c), sourceValue);
                    }
                }
                
                try {
                    System.debug('thisObj: '+ thisObj);
                    
                    if (!String.isBlank(mapObj.Upsert_Object_Field_API_Name__c) && thisObjFlds.containsKey(mapObj.Upsert_Object_Field_API_Name__c))
                        Database.upsert(thisObj, thisObjFlds.get(mapObj.Upsert_Object_Field_API_Name__c));
                    else
                        insert thisObj;
                    
                    System.debug('DATA FIELDS Mapping Obj.Id: ' + mapObj.Id + ' SObject: ' + thisObj);
                    
                    this.objMap.put(mapObj.Id, thisObj);
                } catch (Exception e) {
                    System.debug('ProcessLeadMapping obj save failed: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
                    System.debug('mapObj: ' + mapObj);
                    System.debug('thisObj: ' + thisObj);
                }
            }
	    }
	}
	
	public void finish(Database.BatchableContext BC) {
		Lead_Mapping_Setting__c settings = Lead_Mapping_Setting__c.getOrgDefaults();
		Integer batchSize = (settings != null && settings.Batch_Size__c != null) ? settings.Batch_Size__c.intValue() : 1;

		LeadMappingRefBatch refBatch = new LeadMappingRefBatch(this.theLead, this.theLead.Mapping_Definition_Name__c, this.objMap);

		if (Test.isRunningTest()) {
			refBatch.processRecords(Database.query(refBatch.query));
		} else {
			Database.executeBatch(refBatch, batchSize);
		}
	}
	
}