trigger familyMember on Contact (after insert, after update, after delete) {
if (userinfo.getUserName() != 'cq@noblecx.com.au') {
    if(Trigger.isAfter) {
        
        //Member Collection
        Set<Id> aSet = new Set<Id>();
        
        List<Contact> cList = Trigger.isDelete ? Trigger.Old : Trigger.New;
        
        Map<Id, RecordType> rMap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Contact' AND DeveloperName = 'Family_Member']);
        
        for(Contact c : cList) {
			if(c.AccountId != null && rMap.containsKey(c.RecordTypeId))
                aSet.add(c.AccountId);
        }
        
        if(!aSet.isEmpty())
            campQuality.familyMemberRollup(aSet);
        //End Member Collection
        
    }
}
}