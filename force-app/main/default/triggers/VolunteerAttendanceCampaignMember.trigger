trigger VolunteerAttendanceCampaignMember on Volunteer_Attendance__c (after insert, after update, before delete, after delete) {
    
    if(Trigger.isBefore && Trigger.isDelete) {
        try {
            delete [SELECT Id FROM CampaignMember WHERE Volunteer_Attendance__c IN :Trigger.OldMap.keySet()];
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
    
    if(Trigger.isAfter) {
        
        if(!Trigger.isDelete) {
            
            Map<Id, CampaignMember> cmMap = new Map<Id, CampaignMember>();
            
            for(CampaignMember cm : [SELECT Id, CampaignId, ContactID, Volunteer_Attendance__c, Status, participation__C FROM CampaignMember WHERE Volunteer_Attendance__c IN :Trigger.NewMap.keySet()]) {
                cmMap.put(cm.Volunteer_Attendance__c, cm);
            }
            
            for(Volunteer_Attendance__c va : Trigger.New) {
                //DJA Update exclude Corporate Volunteers.
                if (va.Participation_Role__c != 'Corporate Volunteer'){
                    if(cmMap.containsKey(va.Id)) {
                        //DJA Update to make Vol Member Status prefixed with VOL - 
                        //cmMap.get(va.Id).Status = campQuality.attendanceStatusEquivalent(va.Attendance__c);
                        
                        cmMap.get(va.Id).Status = 'VOL - ' + campQuality.attendanceStatusEquivalent(va.Attendance__c);
                        
                    } else if(String.isNotEmpty(va.Event__c) && String.isNotEmpty(va.Volunteer__c)) {
                        cmMap.put(va.Id, new CampaignMember(CampaignId = va.Event__c, ContactId = va.Volunteer__c, participation__C = va.Participation_Role__c, Volunteer_Attendance__c = va.Id, Status = 'VOL - ' + campQuality.attendanceStatusEquivalent(va.Attendance__c)));
                        
                    }
                }
            }
            List<Database.UpsertResult> results = Database.upsert(cmMap.values(), false);
            
            for(Database.UpsertResult ur : results) {
                if(!ur.isSuccess()) {
                    for(Database.Error err : ur.getErrors()) {
                        System.debug('Error saving Campaign Member: ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                    
                }
            }
            
        }
        
        Set<Id> cSet = new Set<Id>();
        
        if(Trigger.isUpdate || Trigger.isInsert) {
            for(Volunteer_Attendance__c va : Trigger.New) {
                if(String.isNotBlank(va.Volunteer__c)) {
                    cSet.add(va.Volunteer__c);
                }
            }
        }
        
        if(Trigger.isUpdate || Trigger.isDelete) {
            for(Volunteer_Attendance__c va : Trigger.Old) {
                if(String.isNotBlank(va.Volunteer__c)) {
                    cSet.add(va.Volunteer__c);
                }
            }
        }
        
        if(cSet != null && !cSet.isEmpty()) {
            campQuality.volunteerAttendanceRollup(cSet);
        }
        
    }
    
}