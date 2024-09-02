global with sharing class imageInputController {

    public transient string saveImageValue;

    public String conId{get;set;}
    public String eveId{get;set;}
    public String aType{get;set;}
    public String showPortal{get;set;}
    public Boolean replace{get;set;}
    
    public void setsaveImageValue(String n) {
        saveImageValue = n;
    }       
    public String getsaveImageValue()  {
        return saveImageValue;
    }
    
    public String currentImage {get;set;}
    
    public pageReference saveImageData() {
        
        //System.debug('currentImage: ' + currentImage);
        //System.debug('saveImageValue: ' + saveImageValue);

        if(replace) {

        	String query = 'SELECT Id FROM Attachment__c WHERE Attachment_Type__c = :aType ';

        	if(String.isNotEmpty(conId)) {
        		query += ' AND Contact__c = :conId ';
        	}

        	if(String.isNotEmpty(eveId)) {
        		query += ' AND Event__c = :eveId ';
        	}
        
        	if(String.isNotEmpty(eveId) || String.isNotEmpty(conId)) {
	      		try {
	      			delete Database.query(query);
				} catch(DmlException e) {
					System.debug(e);
				}
        	}
        	
        }
        
        Attachment__c a = new Attachment__c();

        a.Attachment_Type__c = aType;
        a.Show_in_Portal__c = showPortal;
        a.Contact__c = conId;
        a.Event__c = eveId;

        try {

        	insert a;

        } catch(DmlException e) {
            
            System.debug(e);

        }

        if(String.isNotEmpty(a.Id)) {

	        /*Attachment attach = new Attachment();
	        
	        attach.isPrivate = false;
	        attach.ParentId = a.Id;
	        attach.ContentType = 'image/jpeg';
	        
	        attach.Name = currentImage;
	        attach.Body = EncodingUtil.base64Decode(saveImageValue.substringAfterLast('base64,'));
	        
	        try {
	            
	            insert attach;
	            
	        } catch (Exception e) {
	            
	            attach.Body = null;
	            attach = null;
	            
	            System.debug(e);
	            
	        } finally {
	            
	            if(attach != null)
	                attach.Body = null;
	                attach = null;

	        }*/
            
            ContentVersion cont = new ContentVersion();
            
            cont.Title = currentImage;
            cont.PathOnClient = currentImage;
            cont.VersionData = EncodingUtil.base64Decode(saveImageValue.substringAfterLast('base64,'));
            cont.Origin = 'H';
            
            try {
                insert cont;
                
                ContentVersion cont2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cont.Id];
                
                insert new ContentDocumentLink(ContentDocumentId = cont2.ContentDocumentId, LinkedEntityId = a.Id, ShareType = 'I');
                
            } catch (Exception e) {
                
                saveImageValue = null;
                cont = null;
                
                System.debug(e);
                
            } finally {
                
                saveImageValue = null;
                cont = null;
                
            }

	    }
        
        currentImage = null;
        saveImageValue = null;
        
        return null;
        
    }
    
}