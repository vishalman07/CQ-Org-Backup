trigger familyAttendance on Family_Attendance__c (after insert, after update, before delete) {
    
    if(!campQuality.inTriggerContext) {
        
        campQuality.inTriggerContext = true;
        
        if(Trigger.isAfter) {
            
            //Generate Family Member Attendance Records
            if(Trigger.isInsert)
                campQuality.familyMemberAttendance(Trigger.New);
            
            if(Trigger.isUpdate) {
                
                Set<Id> faSet = new Set<Id>();
                
                for(Family_Attendance__c fa : Trigger.New) {
                    //if((fa.FA_00000__c == 'Accepted' && Trigger.oldMap.get(fa.Id).FA_00000__c != 'Accepted')
                    //  || (fa.FA_00000__c == 'Declined' && Trigger.oldMap.get(fa.Id).FA_00000__c != 'Declined'))
                    if(fa.FA_00000__c != Trigger.oldMap.get(fa.Id).FA_00000__c)
                        faSet.add(fa.Id);
                }
                
                Set<Id> allSet = new Set<Id>();
                if(!faSet.isEmpty())
                 //campQuality.familyMemberAttendanceUpdate(faSet);
                
                //sync status with campaign member
                
               for(Family_Attendance__c fa : Trigger.New)
                    allSet.add(fa.Id);
                
                campQuality.familtAttendanceCampaignMember(allSet);
            }  
            
            //Attendance Collection
            Set<Id> aSet = new Set<Id>();
            
            List<Family_Attendance__c> faList = Trigger.isDelete ? Trigger.Old : Trigger.New;
            
            for(Family_Attendance__c fa : faList) {
                if((fa.FA_00000__c == 'Attended' || fa.FA_00000__c == 'No Show' || fa.FA_00000__c == 'Unsuccessful' || fa.FA_00000__c == 'Unsuccessful – Waitlist' ||  fa.FA_00000__c == 'Unsuccessful – Declined') && fa.Family__c  != NULL)
                    aSet.add(fa.Family__c);
            }
            
            if(!aSet.isEmpty())
                campQuality.attendanceRollup(aSet);
            //End Attendance Collection
            
            
        }
        
        if(Trigger.isDelete) {
            try {
                delete [SELECT Id FROM CampaignMember WHERE Family_Attendance__c IN :Trigger.OldMap.keySet()];
            } catch(DmlException ex) {
                System.debug(ex);
            }
        }
        
    }
    
}