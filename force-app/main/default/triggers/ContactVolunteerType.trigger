trigger ContactVolunteerType on Volunteer_Type__c (after insert, after update, after delete) {

    Set<Id> cIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate) {
        for(Volunteer_Type__c vt : Trigger.New) {
            cIds.add(vt.Volunteer__c);
        }
    }
    
    if(Trigger.isDelete || Trigger.isUpdate) {
        for(Volunteer_Type__c vt : Trigger.Old) {
            cIds.add(vt.Volunteer__c);
        }
    }
    
    System.debug(cIds);
    
    if(cIds.size() > 0) {
        
        List<Contact> vols = new List<Contact>();
        
        for(Contact c : [SELECT Id, Volunteer_Types__c, 
                         (SELECT Id, Volunteer_Type__c, Volunteer_Status__c, Start_Date__c, End_Date__c 
                          FROM Volunteers_Type__r WHERE Volunteer_Status__c <> 'Inactive' AND Start_Date__c <= :Date.today() AND (End_Date__c = NULL OR End_Date__c >= :Date.today())) 
                         FROM Contact 
                         WHERE Id IN :cIds]) {
            system.debug('c ===>>>'+c);
            Set<String> vTypes = new Set<String>();
            set<String> vTypesAll = new Set<string>();                          
            
            for(Volunteer_Type__c vt : c.Volunteers_Type__r) {
                system.debug('vt.Volunteer_Status__c ===>>'+vt.Volunteer_Status__c);
                if (vt.Volunteer_Status__c == 'Active') {
                    system.debug('inside if status trigger ===>>'+vt.Volunteer_Type__c);
                    vTypes.add(vt.Volunteer_Type__c);
                    system.debug('vtypes ===>>>'+vTypes);
                }
                vTypesAll.add(vt.Volunteer_Type__c);
                system.debug('vtypes ===>>>'+vTypesAll);
            }
            system.debug('vTypes==>>'+vTypes);
            if(vTypes.size() > 0) {
                system.debug('inside if vTypes==>>'+vTypes);
                c.Volunteer_Types__c = String.join(new List<String>(vTypes), ';');
            } else {
                system.debug('inside else vTypes==>>'+vTypes);
                c.Volunteer_Types__c = '';
            }
            
            if(vTypesAll.size() > 0) {
                c.Volunteer_Types_Training__c = String.join(new List<String>(vTypesAll), ';');
            } else {
                c.Volunteer_Types_Training__c = '';
            }
            vols.add(c);
        }
         System.debug(vols);
        
        if(vols.size() > 0) {
            try {
                system.debug('vols==>>'+vols);
                update vols;
            } catch(DmlException ex) {
                System.debug(ex);
            }
        }
        
        
    }
    
}