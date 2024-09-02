global class ProcessLeadMapping {
    
    @AuraEnabled
    webservice static String ProcessLead(Id leadId) {
        Lead_Mapping_Setting__c settings = Lead_Mapping_Setting__c.getOrgDefaults();
        Integer batchSize = (settings != null && settings.Batch_Size__c != null) ? settings.Batch_Size__c.intValue() : 1;
        if (Test.isRunningTest())
            batchSize = 200;
            
        Id jobId = Database.executeBatch(new LeadMappingDataBatch(leadId), batchSize);

        return 'Lead Process Mapping queued for execution; JobId: ' + jobId;

        /*
        // get lead fields
        String leadQuery = 'SELECT ';
        Map<String, Map<String, Schema.SObjectField>> sobjFldMaps = new Map<String, Map<String, Schema.SObjectField>>{
            'Lead' =>  Schema.SObjectType.Lead.fields.getMap()   
                };
        
        for (Schema.SObjectField fld : sobjFldMaps.get('Lead').values())
            leadQuery += fld.getDescribe().getName() + ',';
        
        leadQuery = leadQuery.subString(0, leadQuery.length() - 1);
        
        leadQuery += ' FROM Lead WHERE Id = \'' + leadId + '\' LIMIT 1';
        
        System.debug(LoggingLevel.DEBUG, 'ProcessLeadMapping leadQuery: ' + leadQuery);
        
        Lead theLead = (Lead)Database.query(leadQuery);
        
        String definitionName = theLead.Mapping_Definition_Name__c;
        
        if (String.isBlank(definitionName))
        	return new List<String>{'Lead has no Mapping Definition Name'};

        Map<Id, Mapping_Object__c> mappingObjs = new Map<Id, Mapping_Object__c>(
            [SELECT Id, Name, Definition__c, Object_API_Name__c, Upsert_Object_Field_API_Name__c,
             (SELECT Id, Field_API_Name__c, Source_Fields__c, Default_Value__c FROM Mapping_Fields__r),
             (SELECT Id, Reference_Field_API_Name__c, Referenced_Object_API_Name__c, Reference_Type__c, Defined_Object__c, Id_ExtId_Value__c, Referenced_Object_ExtId_API_Name__c FROM Mapping_References__r)
             FROM	  Mapping_Object__c 
             WHERE  Definition__c =: theLead.Mapping_Definition_Name__c]);
        
        if (!mappingObjs.isEmpty()) {
            Map<String, Schema.SObjectType> allSObjTypes = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> leadFlds = sobjFldMaps.get('Lead');
            // Mapping_Object__c.Id => new SObject...
            Map<Id, SObject> objMap = new Map<Id, SObject>();
            
            Set<Id> createdIds = new Set<Id>();

            for (Mapping_Object__c mapObj : mappingObjs.values()) {
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
                            
                            data(thisObj, thisObjFlds.get(mapFld.Field_API_Name__c), sourceValue);
                        }
                    }
                    
                    try {
                        if (!String.isBlank(mapObj.Upsert_Object_Field_API_Name__c) && thisObjFlds.containsKey(mapObj.Upsert_Object_Field_API_Name__c))
                            Database.upsert(thisObj, thisObjFlds.get(mapObj.Upsert_Object_Field_API_Name__c));
                        else
                            insert thisObj;
                        
                        createdIds.add(thisObj.Id);

                        System.debug(LoggingLevel.DEBUG, 'DATA FIELDS Mapping Obj.Id: ' + mapObj.Id + ' SObject: ' + thisObj);
                        
                        objMap.put(mapObj.Id, thisObj);
                    } catch (Exception e) {
                        System.debug(LoggingLevel.DEBUG, 'ProcessLeadMapping obj save failed: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
                        System.debug(LoggingLevel.DEBUG, 'mapObj: ' + mapObj);
                        System.debug(LoggingLevel.DEBUG, 'thisObj: ' + thisObj);
                    }
                }
            }
            
            

            // process references here..
            for (Mapping_Object__c mapObj : mappingObjs.values()) {
                if (mapObj.Mapping_References__r != null && !mapObj.Mapping_References__r.isEmpty()) {
                    if (objMap.containsKey(mapObj.Id)) {
                        SObject thisObj = objMap.get(mapObj.Id);
                        Map<String, Schema.SObjectField> thisObjFlds = sobjFldMaps.get(mapObj.Object_API_Name__c);
                        
                        for (Mapping_Reference__c mapRef : mapObj.Mapping_References__r) {
                            if (thisObjFlds.containsKey(mapRef.Reference_Field_API_Name__c)) {
                                if (mapRef.Reference_Type__c == 'Id Value') {
                                    thisObj.put(mapRef.Reference_Field_API_Name__c, mapRef.Id_ExtId_Value__c);
                                } else if (mapRef.Reference_Type__c == 'SObject Definition') {
                                    if (objMap.containsKey(mapRef.Defined_Object__c))
                                    	thisObj.put(mapRef.Reference_Field_API_Name__c, objMap.get(mapRef.Defined_Object__c).Id);
                                } else if (mapRef.Reference_Type__c == 'External Id Value') {
                                    if (allSObjTypes.containsKey(mapRef.Referenced_Object_API_Name__c)) {
                                        SObject refObj = allSObjTypes.get(mapRef.Referenced_Object_API_Name__c).newSObject();
                                        refObj.put(mapRef.Referenced_Object_ExtId_API_Name__c, mapRef.Id_ExtId_Value__c);
                                        Schema.DescribeFieldResult refDfr = thisObjFlds.get(mapRef.Reference_Field_API_Name__c).getDescribe();
                                        
                                        thisObj.putSObject(refDfr.getRelationshipName(), refObj);
                                    }
                                }
                            } else if (mapRef.Reference_Type__c == 'Join Object') {
                            	if (allSObjTypes.containsKey(mapRef.Referenced_Object_API_Name__c) && objMap.containsKey(mapRef.Defined_Object__c)) {
                            		SObject joinObj = allSObjTypes.get(mapRef.Referenced_Object_API_Name__c).newSObject();
                            		joinObj.put(mapRef.Reference_Field_API_Name__c, thisObj.Id);
                            		joinObj.put(mapRef.Referenced_Object_ExtId_API_Name__c, objMap.get(mapRef.Defined_Object__c).Id);

                            		try {
	                            		insert joinObj;
	                            		createdIds.add(joinObj.Id);

	                            		System.debug(LoggingLevel.DEBUG, 'REF Join Object: ' + joinObj);
	                            	} catch (Exception e) {
	                            		System.debug(LoggingLevel.DEBUG, 'ProcessLeadMapping Join Object failed: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
	                            	}
                            	}
                            }
                        }
                        
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

            List<String> ret = new List<String>();
            String sfBaseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';

            for (Id objId : new List<Id>(createdIds))
            	ret.add(sfBaseUrl + objId);

            return ret;
        } else {
        	return new List<String>{'Found no Mapping Objects for Definition Name ' + definitionName};
        }
        */
    }
    
    public static void data(SObject obj, Schema.SObjectField objFld, String value) {
        Schema.DescribeFieldResult dfr = objFld.getDescribe();
        String fldName = dfr.getName();
        String fldType = String.valueOf(dfr.getType());
        
        if(fldType == 'DATE') {
            DateTime dt = ParseDT(value);
            if (dt != null)
                obj.put(fldName, dt.date());
        } else if (fldType == 'DATETIME') {
            DateTime dt = ParseDT(value);
            if (dt != null)
                obj.put(fldName, dt);
        } else if(fldType == 'BOOLEAN') {
            
            Boolean tempBool = false;  
            
            if(value == 'Yes' || value == '1') {
                tempBool = true;
            }
            
            obj.put(fldName, tempBool);
            
        } else if(fldType == 'DECIMAL' || fldType == 'CURRENCY' || fldType == 'DOUBLE') {    
            
            String tempVal = value.replace('$','');
            
            try {
                
                obj.put(fldName, Decimal.valueOf(tempVal));
                
            } catch(Exception e) {
                System.debug(LoggingLevel.DEBUG, 'Data Fail (Decimal): ' + fldName + ', ' + tempVal);
            }
            
        } else {
            
            try {
                
                obj.put(fldName, value);
                
            } catch(Exception e) {
                System.debug(LoggingLevel.DEBUG, 'Data Fail: ' + fldName + ', ' + value + ' ('+fldType+')');
            }
            
        }
    }
    
    private static DateTime ParseDT(String value) {
        String dateStr, timeStr;
        
        if (value == null)
            return null;

        if (value.contains(' ')) {
            dateStr = value.substring(0, value.indexOf(' '));
            timeStr = value.substring(value.indexOf(' '));
        } else if (value.contains('T')) {
            dateStr = value.substring(0, value.indexOf('T'));
            timeStr = ' ' + value.substring(value.indexOf('T') + 1);
        } else {
            dateStr = value;
            timeStr = ' 12:00:03 AM';
        }
        
        List<String> dateParts = new List<String>();
        
        for (String dateSplit : new Set<String>{'.', '/', '-'}) {
            if (dateStr.contains(dateSplit)) {
                dateParts.addAll(dateStr.split(dateSplit));
                break;
            }
        }
                
        if (dateParts != null && dateParts.size() == 3) {
            if (dateParts.get(0).length() > 2)
                dateStr = dateParts.get(2) + '/' + dateParts.get(1) + '/' + dateParts.get(0);
            else
                dateStr = dateParts.get(0) + '/' + dateParts.get(1) + '/' + dateParts.get(2);
            
            String useMeridiem;
            
            if (timeStr.containsIgnoreCase('AM'))
                useMeridiem = ' AM';
            else if (timeStr.containsIgnoreCase('PM'))
                useMeridiem = ' PM';
            
            List<String> timeParts = timeStr.split(':');
            if (timeParts.size() > 2)
                timeParts = new List<String>{timeParts.get(0), timeParts.get(1)};
                    
                    timeStr = String.join(timeParts, ':');
            if (useMeridiem != null && !timeStr.containsIgnoreCase('M'))
                timeStr += useMeridiem;
            
            // Assume 24hr when no AM/PM
            if (!timeStr.containsIgnoreCase('M')) {
                Integer hour;
                Integer minute;
                Boolean afterMidday = false;
                
                try {
                    hour = Integer.valueOf(timeParts.get(0).normalizeSpace());
                    minute = Integer.valueOf(timeParts.get(1).normalizeSpace());
                    
                    if (hour > 12) {
                        afterMidday = true;
                        hour -= 12;
                    }
                    
                    timeStr = ' ' + hour + ':' + minute + (afterMidday ? ' PM' : ' AM');

                    if (timeStr == ' 0:0 AM') 
                        timeStr = ' 12:00 AM';
                } catch (Exception e) {
                    System.debug(LoggingLevel.DEBUG, 'ParseDT Exception (time without AM/PM): ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
                }
            }
            
            try {
                
                System.debug(LoggingLevel.DEBUG, 'ParseDT(' + value + '): dateStr: ' + dateStr + ' timeStr: ' + timeStr + ' DateTime.parse(' + dateStr + timeStr + ')');
                DateTime dt = DateTime.parse(dateStr + timeStr);
                return dt;
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, 'ParseDT Exception: ' + e.getTypeName() + ' ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
            }
        }
        
        return null;
    }
}