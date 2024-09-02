global class vertic_UpdateRecordsBatch implements Database.Batchable<SObject> {
    global SObjectType sObjectType;
    global List<String> conditions;
    global Map<Id, SObject> recordsMap;

    global vertic_UpdateRecordsBatch(SObjectType sObjectType, String condition) {
        this(sObjectType, String.isNotBlank(condition) ? new List<String>{condition} : new List<String>());
    }

    global vertic_UpdateRecordsBatch(SObjectType sObjectType, List<String> conditions) {
        this(sObjectType, new Map<Id, SObject>(), conditions);
        this.sObjectType = sObjectType;
        this.conditions = conditions;
    }

    global vertic_UpdateRecordsBatch(Map<Id, SObject> recordsMap, List<String> conditions) {
        this(recordsMap.values().get(0).getSObjectType(), recordsMap, conditions);
    }
    global vertic_UpdateRecordsBatch(SObjectType sObjectType, Map<Id, SObject> recordsMap, List<String> conditions) {
        this.sObjectType = sObjectType;
        this.conditions = conditions == null ? new List<String>() : conditions;
        this.recordsMap = recordsMap;
        if (recordsMap != null && recordsMap.size() > 0) {
            Set<String> ids = npsp_plus.vertic_Utils.sObjects.getStringFieldValues(recordsMap.values(), 'Id');
            this.conditions.add('Id IN (\'' + String.join(new List<String>(ids), '\', \'') + '\')');
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id FROM ' + sObjectType.getDescribe().getLocalName();
        if (conditions != null && conditions.size() > 0) {
            queryString += ' WHERE ' + String.join(conditions, ' AND ');
        }
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Map<Id, SObject> recordsToUpdate = new Map<Id, SObject>();
        for (SObject sObj : scope) {
            if (recordsMap != null && recordsMap.containsKey(sObj.Id)) {
                SObject record = recordsMap.get(sObj.Id);
                recordsToUpdate.put(record.Id, record);
            } else {
                recordsToUpdate.put(sObj.Id, sObj);
            }
        }
        Database.update(recordsToUpdate.values(), false);
    }

    global void finish(Database.BatchableContext BC) {}
}