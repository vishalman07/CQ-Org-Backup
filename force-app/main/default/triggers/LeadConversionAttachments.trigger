trigger LeadConversionAttachments on Contact (after insert) {
if (userinfo.getUserName() != 'cq@noblecx.com.au') {
    Set<Id> lIds = new Set<Id>();
    
    for(Contact c : Trigger.New) {
        if(String.isNotBlank(c.Attachment_Lead__c)) {
            lIds.add(c.Attachment_Lead__c);
        }
    }
    
    Map<Id, List<Attachment>> attachMap = new Map<Id, List<Attachment>>();
    Map<Id, Lead> fileMap = new Map<Id, Lead>([SELECT Id, (SELECt Id, ContentDocumentId, LinkedEntityId, ShareType FROM ContentDocumentLinks) FROM Lead WHERE Id IN :lIds]);
    
    List<Attachment> insAs = new List<Attachment>();
    List<ContentDocumentLink> insCdls = new List<ContentDocumentLink>();
    
    for(Attachment a : [SELECT Id, Name, isPrivate, ContentType, ParentId, Body FROM Attachment WHERE ParentId IN :lIds]) {
        if(!attachMap.containsKey(a.ParentId)) {
            attachMap.put(a.ParentId, new List<Attachment>());
        }
        attachMap.get(a.ParentId).add(a);
    }
    
    //Map<Attachment, Attachment__c> aaMap = new Map<Attachment, Attachment__c>();
    //Map<ContentDocumentLink, Attachment__c> acMap = new Map<ContentDocumentLink, Attachment__c>();
    
    for(Contact c : Trigger.New) {
        if(String.isBlank(c.Attachment_Lead__c))
            continue;
        
        if(attachMap.containsKey(c.Attachment_Lead__c)) {
            
            for(Attachment att : attachMap.get(c.Attachment_Lead__c)) {
                //Attachment__c a = new Attachment__c();
                //a.Contact__c = c.Id;
                
                Attachment newAtt = att.clone();
                newAtt.ParentId = c.Id;
                insAs.add(newAtt);
                //aaMap.put(newAtt, a);
            }
            
        }
        
        if(fileMap.containsKey(c.Attachment_Lead__c) && fileMap.get(c.Attachment_Lead__c).ContentDocumentLinks != null && !fileMap.get(c.Attachment_Lead__c).ContentDocumentLinks.isEmpty()) {
            
            for(ContentDocumentLink cdl : fileMap.get(c.Attachment_Lead__c).ContentDocumentLinks) {
                //Attachment__c a = new Attachment__c();
                //a.Contact__c = c.Id;
                
                ContentDocumentLink newCdl = cdl.clone();
                newCdl.LinkedEntityId = c.Id;
                insCdls.add(newCdl);
                
                //acMap.put(newCdl, a);
            }
            
        }
        
    }
    
    /*List<Attachment__c> insertAttaches = new List<Attachment__c>();
    insertAttaches.addAll(aaMap.values());
    insertAttaches.addAll(acMap.values());
    
    if(!insertAttaches.isEmpty()) {
        try {
            insert insertAttaches;
        } catch(DmlException ex) {
            System.debug(ex);
        }
        
        for(Attachment a : aaMap.keySet()) {
            Attachment__c att = aaMap.get(a);
            a.ParentId = att.Id;
            insAs.add(a);
        }
        
        for(ContentDocumentLink cdl : acMap.keySet()) {
            Attachment__c att = acMap.get(cdl);
            cdl.LinkedEntityId = att.Id;
            insCdls.add(cdl);
        }
        
    }*/
    
    if(!insAs.isEmpty()) {
        try {
            insert insAs;
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
    
    if(!insCdls.isEmpty()) {
        try {
            insert insCdls;
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
}
}