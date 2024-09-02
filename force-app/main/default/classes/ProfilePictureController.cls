public with sharing class ProfilePictureController {
    
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {

        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
            
        }
        
        List<Attachment__c> attaches = [SELECT Id FROM Attachment__c WHERE Contact__c = :parentId AND Attachment_Type__c = 'Profile Image' ORDER BY LastModifiedDate DESC];
 
        if(!attaches.isEmpty()) {
            return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
                    WHERE parentid=:attaches[0].Id AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
                    ORDER BY LastModifiedDate DESC LIMIT 1];
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 

        // Edit permission on parent object (Contact) is required to add attachments
        if (!Schema.sObjectType.Contact.isUpdateable()) {
            throw new System.NoAccessException();
            
        }
        
        List<Attachment__c> attaches = [SELECT Id FROM Attachment__c WHERE Contact__c = :parentId AND Attachment_Type__c = 'Profile Image' ORDER BY LastModifiedDate DESC];
 		Attachment__c attach;
        
        if(attaches.isEmpty()) {
            attach = new Attachment__c(Contact__c = parentId, Show_in_Portal__c = 'Both', Attachment_Type__c = 'Profile Image');
            
            try {
                insert attach;
            } catch(DmlException ex) {
                System.debug(ex);
            }
        } else {
            attach = attaches[0];
        }
        
        if(String.isNotEmpty(attach.Id)) {
            Attachment attachment = new Attachment();
            attachment.parentId = attach.Id;
            attachment.body = EncodingUtil.base64Decode(base64Data);
            attachment.name = fileName;
            attachment.contentType = contentType;
            
            try {
                insert attachment;
            } catch(DmlException ex) { 
                System.debug(ex);
            }
            
            return attachment.id;
        } else {
            return null;
        }
        
    }

}