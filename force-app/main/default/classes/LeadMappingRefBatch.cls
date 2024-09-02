public class LeadMappingRefBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	public String query;
	Map<Id, SObject> objMap;
    Lead theLead;
	Id leadId;

	 public LeadMappingRefBatch(Lead dataLead, String mappingDefinitionName, Map<Id, SObject> oMap) {
		this.query = 'SELECT Id, Defined_Object__c, Id_ExtId_Value__c, Referenced_Object_API_Name__c, Referenced_Object_ExtId_API_Name__c, ' + 
                            ' Reference_Field_API_Name__c, Reference_Type__c, Process_Order__c, Upsert_Field_API_Name__c, Mapping_Object__c, ' + 
                             ' Mapping_Object__r.Id, Mapping_Object__r.Object_API_Name__c, ' + 
                             ' (SELECT Id, Field_API_Name__c, Source_Fields__c, Default_Value__c FROM Mapping_Fields__r) ' +
                    ' FROM Mapping_Reference__c ' + 
                    ' WHERE Mapping_Object__r.Definition__c = \'' + String.escapeSingleQuotes(mappingDefinitionName) + '\' ' +
                    ' ORDER BY Process_Order__c';
        this.objMap = oMap;
        this.theLead = dataLead;
		this.leadId = this.theLead.Id;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	public void processRecords(List<SObject> scope) {
		Map<String, Schema.SObjectType> allSObjTypes = Schema.getGlobalDescribe();
		Map<String, Map<String, Schema.SObjectField>> sobjFldMaps = new Map<String, Map<String, Schema.SObjectField>>();

		for (SObject sobj : scope) {
	    	Mapping_Reference__c mapRef = (Mapping_Reference__c)sobj;
            Mapping_Object__c mapObj = mapRef.Mapping_Object__r;

            System.debug(mapRef.Reference_Type__c + ' mapRef: ' + mapRef);
            System.debug('objMap.containsKey(mapObj.Id: ' + mapObj.Id + '): ' + objMap.containsKey(mapObj.Id) + ' objMap.get(): ' + objMap.get(mapObj.Id));

	    	if (!sobjFldMaps.containsKey(mapObj.Object_API_Name__c))
            	sobjFldMaps.put(mapObj.Object_API_Name__c, allSObjTypes.get(mapObj.Object_API_Name__c).getDescribe().fields.getMap());

        	if (objMap.containsKey(mapObj.Id)) {
                SObject thisObj = this.objMap.get(mapObj.Id);
                Map<String, Schema.SObjectField> thisObjFlds = sobjFldMaps.get(mapObj.Object_API_Name__c);
                Boolean updateThisObj = false;

                System.debug('thisObj: ' + thisObj.getSObjectType() + ' has Reference_Field_API_Name__c: ' + mapRef.Reference_Field_API_Name__c + ' ? ' + thisObjFlds.containsKey(mapRef.Reference_Field_API_Name__c));

                if (thisObjFlds.containsKey(mapRef.Reference_Field_API_Name__c)) {
                    if (mapRef.Reference_Type__c == 'Id Value') {
                        if (String.isNotBlank(mapRef.Id_ExtId_Value__c)) {
                            thisObj.put(mapRef.Reference_Field_API_Name__c, mapRef.Id_ExtId_Value__c);
                            updateThisObj = true;
                        }
                    } else if (mapRef.Reference_Type__c == 'SObject Definition') {
                        if (objMap.containsKey(mapRef.Defined_Object__c)) {
                        	thisObj.put(mapRef.Reference_Field_API_Name__c, objMap.get(mapRef.Defined_Object__c).Id);
                            updateThisObj = true;
                        }
                    } else if (mapRef.Reference_Type__c == 'External Id Value') {
                        if (allSObjTypes.containsKey(mapRef.Referenced_Object_API_Name__c)) {
                            SObject refObj = allSObjTypes.get(mapRef.Referenced_Object_API_Name__c).newSObject();
                            refObj.put(mapRef.Referenced_Object_ExtId_API_Name__c, mapRef.Id_ExtId_Value__c);
                            Schema.DescribeFieldResult refDfr = thisObjFlds.get(mapRef.Reference_Field_API_Name__c).getDescribe();
                            
                            thisObj.putSObject(refDfr.getRelationshipName(), refObj);
                            updateThisObj = true;
                        }
                    }
                } else if (mapRef.Reference_Type__c == 'Join Object') {
                	System.debug('JOIN OBJ; Referenced_Object_API_Name__c: ' + mapRef.Referenced_Object_API_Name__c);
                    if (allSObjTypes.containsKey(mapRef.Referenced_Object_API_Name__c) && !sobjFldMaps.containsKey(mapRef.Referenced_Object_API_Name__c))
                        sobjFldMaps.put(mapRef.Referenced_Object_API_Name__c, allSObjTypes.get(mapRef.Referenced_Object_API_Name__c).getDescribe().fields.getMap());
                    
                    if (sobjFldMaps.containsKey(mapRef.Referenced_Object_API_Name__c)) {
                		SObject joinObj = allSObjTypes.get(mapRef.Referenced_Object_API_Name__c).newSObject();
                		joinObj.put(mapRef.Reference_Field_API_Name__c, thisObj.Id);
                		
                        if (String.isNotBlank(mapRef.Referenced_Object_ExtId_API_Name__c) || String.isNotBlank(mapRef.Defined_Object__c)) {
                            if (String.isBlank(mapRef.Referenced_Object_ExtId_API_Name__c) || String.isBlank(mapRef.Defined_Object__c) || !objMap.containsKey(mapRef.Defined_Object__c) || String.isBlank(objMap.get(mapRef.Defined_Object__c).Id))
                                continue;
                                // invalid master detail join object (both lookups being set..)
                            joinObj.put(mapRef.Referenced_Object_ExtId_API_Name__c, objMap.get(mapRef.Defined_Object__c).Id);
                        }// else {
                            // no logic here but just singular M-D lookup being set.
                        //}

                        Map<String, Schema.SObjectField> joinObjFlds;

                        if (mapRef.Mapping_Fields__r != null && !mapRef.Mapping_Fields__r.isEmpty()) {
                            if (!sobjFldMaps.containsKey('Lead'))
                                sobjFldMaps.put('Lead', allSObjTypes.get('Lead').getDescribe().fields.getMap());

                            joinObjFlds = sobjFldMaps.get(mapRef.Referenced_Object_API_Name__c);
                            Map<String, Schema.SObjectField> leadFlds = sobjFldMaps.get('Lead');

                            for (Mapping_Field__c mapFld : mapRef.Mapping_Fields__r) {
                                if (joinObjFlds.containsKey(mapFld.Field_API_Name__c)) {
                                    String sourceValue = '';

                                    if (String.isNotBlank(mapFld.Source_Fields__c)) {
                                        if (mapFld.Source_Fields__c.contains('+')) {
                                            for (String srcFld : mapFld.Source_Fields__c.split('\\+')) {
                                                if (leadFlds.containsKey(srcFld)) {
                                                    if (this.theLead.get(srcFld) != null)
                                                        sourceValue += String.valueOf(this.theLead.get(srcFld));
                                                } else {
                                                    sourceValue += srcFld;
                                                }
                                            }
                                        } else if (leadFlds.containsKey(mapFld.Source_Fields__c)) {
                                            sourceValue = String.valueOf(this.theLead.get(mapFld.Source_Fields__c));
                                        }
                                    }

                                    if (String.isBlank(sourceValue) && String.isNotBlank(mapFld.Default_Value__c))
                                        sourceValue = mapFld.Default_Value__c;

                                    if (String.isBlank(sourceValue))
                                        sourceValue = null;

                                    ProcessLeadMapping.data(joinObj, joinObjFlds.get(mapFld.Field_API_Name__c), sourceValue);
                                }
                            }
                        }

                		try {
                            System.debug(LoggingLevel.ERROR, 'REF Join Object; about to insert: ' + joinObj);

                    		if (String.isNotBlank(mapRef.Upsert_Field_API_Name__c))
                                Database.upsert(joinObj, joinObjFlds.get(mapRef.Upsert_Field_API_Name__c));
                            else
                                insert joinObj;

                    		System.debug(LoggingLevel.DEBUG, 'REF Join Object: ' + joinObj);
                    	} catch (Exception e) {
                    		System.debug(LoggingLevel.DEBUG, 'ProcessLeadMapping Join Object failed: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
                    	}
                	}
                }
                
                if (updateThisObj) {
                    try {
                        update thisObj;
                        
                        System.debug(LoggingLevel.DEBUG, 'REF FIELDS Mapping Obj.Id: ' + mapObj.Id + ' SObject: ' + thisObj);
                    } catch (Exception e) {
                        System.debug(LoggingLevel.DEBUG, 'ProcessLeadMapping updating references failed: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
                        System.debug(LoggingLevel.DEBUG, 'thisObj: ' + thisObj);
                    }
                }
            }
	    }
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		this.processRecords(scope);
	}
	
	public void finish(Database.BatchableContext BC) {
		Lead l = new Lead(Id=this.leadId, Lead_Mapping_Processed__c=true);

		try {
			update l;
		} catch (Exception e) {
			System.debug('LeadMappingRefBatch Error updating Lead as Mapping Processed: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
			System.debug('LeadMappingRefBatch Lead: ' + l);
		}
	}
	
}