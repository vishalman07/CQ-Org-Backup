trigger LeadVolunteerTypes on Lead (after update) {
    
    RecordType rType;
    for(RecordType rt : [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'Volunteer']) {
        rType = rt;
    }
    
    if(rType == null) return;
    
    Set<String> lIds = new Set<String>();
    
    for(Lead l : Trigger.New) {
        if(l.RecordTypeId == rType.Id && l.Lead_Mapping_Processed__c && !Trigger.OldMap.get(l.Id).Lead_Mapping_Processed__c) {
            lIds.add(l.Id);
        }
    }
    
    Map<String, Contact> conMap = new Map<String, Contact>();
    
    for(Contact c : [SELECT Id,	Attachment_Lead__c, (SELECT Id, Volunteer_Type__c FROM Volunteers_Type__r) FROM Contact WHERE Attachment_Lead__c IN :lIds]) {
        conMap.put(c.Attachment_Lead__c, c);
    }
    
    List<Volunteer_Type__c> volTypes = new List<Volunteer_Type__c>();
    
    for(Lead l : Trigger.New) {
        if(l.RecordTypeId == rType.Id && l.Lead_Mapping_Processed__c && !Trigger.OldMap.get(l.Id).Lead_Mapping_Processed__c && conMap.containsKey(l.Id)) {
            Set<String> exVTs = new Set<String>();
            
            if(conMap.get(l.Id).Volunteers_Type__r != null) {
                for(Volunteer_Type__c vt : conMap.get(l.Id).Volunteers_Type__r) {
                    exVTs.add(vt.Volunteer_Type__c);
                }
            } 
            
            List<String> vTypes = l.Volunteer_Type__c.split(';');
            for(String vt : vTypes) {
                if(!exVTs.contains(vt)) {
                    volTypes.add(new Volunteer_Type__c(
                        Volunteer__c = conMap.get(l.Id).Id,
                        Start_Date__c = Date.today(),
                        Volunteer_Type__c = vt,
                        Volunteer_Status__c = 'Active'
                    ));
                }
            }
        }
    }

    if(!volTypes.isEmpty()) {
        try {
            insert volTypes;
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
    
}