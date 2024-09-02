public class SendBulkEmailController {

    public string strType { get; set; }
    public string strSubject { get; set; }
    public string strMessage { get; set; }
    public ID templateId { get; set; }
    public integer numberOfContacts { get; set; }
    public ID fromEmailId { get; set; }
    public string strJobName { get; set; }
    public boolean fLogActivity { get; set; }
    public boolean fEmailContactsOnlyOnce { get; set; }

    public String campaignMemberType {get; set; }

    public ID folderId { get; set; }
    public ID campaignId { get; set; }
    public ID testWhoID {get; set; }
    public ID testRelatedID {get; set;}
    
    
    public Boolean updateCmStatus{get;set;}
    
    public String trStatus{get;set;}
    public String cmStatus{get;set;}
  
    public String getBaseUrl(){
    return System.URL.getSalesforceBaseUrl().toExternalForm();
}
public String getContentUrl(){
    return System.URL.getSalesforceBaseUrl().toExternalForm().replace('.visual.force.com','.content.force.com');
} 
    // constructor
    public SendBulkEmailController() { 
        
        // figure out what object we were invoked from
        campaignId = ApexPages.currentPage().getParameters().get('campaignId');
        fEmailContactsOnlyOnce = false;
        testwhoid=campaignId;
        testRelatedID=campaignId;
        if (campaignId != null) {
            Campaign cmp = [select Name from Campaign where Id = :campaignId];
            strJobName = cmp.Name;
            templateObject = 'Campaign';                    
            // in the Campaign case, default to Unique Contacts
            fEmailContactsOnlyOnce = true;
        }
        
        numberOfContacts = 0;
        fLogActivity = false;
        fEmailContactsOnlyOnce = false;
        
        list<Folder> listf = [select Id from Folder where DeveloperName='My_Camp_Quality'];
        if (listf.size() > 0) folderId = listf[0].Id;       
        updateCmStatus =true;
        StatusChanged();
    }
    
    // the list of Email Templates
    public list<SelectOption> getlistEmailFolders() {
        list<SelectOption> listSO = new list<SelectOption>();
        listSO.add(new SelectOption('', '--Please Select--'));
        for (Folder et :[select Id, Name from Folder where Type = 'Email' AND AccessType = 'Public']) {
            listSO.add(new SelectOption(et.id, et.name));
        }       
        return listSO;
    }   
        
    // the list of Email Templates
    public list<SelectOption> getlistSOTemplates() {
        list<SelectOption> listSO = new list<SelectOption>();
        listSO.add(new SelectOption('', '--Please Select--'));
        for (EmailTemplate et : [select Id, Name, Subject, Body from EmailTemplate 
                where isActive=true and FolderId=:folderId order by name limit 999]) {
            listSO.add(new SelectOption(et.id, et.name));
        }       
        return listSO;
    }   
    
    // the list of Org Wide Email Addresses
    public list<SelectOption> getlistSOFromEmails() { 
        list<SelectOption> listSO = new list<SelectOption>();
        User thisUser = [Select Name, Email from User where id = :UserInfo.getUserId()];
        listSO.add(new SelectOption('', thisUser.Name + ' <' + thisUser.Email + '>'));
        for (OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]) {
            listSO.add(new SelectOption(owa.id, owa.DisplayName + ' <' + owa.Address + '>'));
        }       
        return listSO;
    }
    
    public List<SelectOption> getTrStatuses() {
     
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('', '--Please Select--'));
        
        Schema.DescribeFieldResult fieldResult =
            CampaignMember.Attendance__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        
        return options;
        
    }
    
    public List<SelectOption> getCmStatuses() {
     
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('', '--Please Select--'));
        
        Schema.DescribeFieldResult fieldResult =
            CampaignMember.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        
        return options;
        
    }
    
    public string templateObject { get{return 'Campaign';} set; }
    
    // action method to load up the email template the user has chosen
    public PageReference LoadEmailTemplate() {
        if (templateId != null) {
            EmailTemplate et = [select Id, Name, Subject, HtmlValue, Body, TemplateType from EmailTemplate where Id = :templateId];
            
            System.debug('et: ' + et);
            strType = et.TemplateType;
            strSubject = et.Subject;
            strMessage = (et.HtmlValue != null) ? et.HtmlValue : et.Body;
        } else {
            strType = null;
            strSubject = null;
            strMessage = null;      
        }
        return null;
    }
    
    // action method to view the templates folder
    public PageReference OpenEmailTemplateFolder() {
        if (folderId != null) {
            PageReference p = new PageReference('/' + folderId);
            p.setRedirect(true);
            return p;
        }
        return null;
    }

    // action method to view the templates folder
    public PageReference EditEmailTemplate() {
        if (templateId != null) {
            PageReference p = new PageReference('/' + templateId);
            p.setRedirect(true);
            return p;
        }
        return null;
    }

    // action method called when status picklist has changed.  requery for number of contacts to email.
    public PageReference StatusChanged() {
        
        list<CampaignMember> listHr;
        
        if(campaignId != null) {
            // Salesforce failed to match our campaignId against the formula field which is text, so use full reference.
// DJA 23/7/2017 Add family attendance and Vol attendance so we can preview template. 
            String query = 'select ContactId,Volunteer_Attendance__c, Family_Attendance__c from CampaignMember where CampaignId = :campaignId ';
             
            if(String.isNotBlank(trStatus)) {
                query += ' AND Status = :trStatus ';
            } 

            if(campaignMemberType == 'Volunteer') {
                query += ' AND Volunteer_Attendance__c <> NULL AND Volunteer_Attendance__r.Registration_Type__c <> NULL AND Volunteer_Attendance__r.Registration_Type__r.RecordType.DeveloperName <> \'Corporate_Volunteer\' ';
            }
            
            if(campaignMemberType == 'Corporate Volunteer') {
                query += ' AND Volunteer_Attendance__c <> NULL AND Volunteer_Attendance__r.Registration_Type__c <> NULL AND Volunteer_Attendance__r.Registration_Type__r.RecordType.DeveloperName = \'Corporate_Volunteer\' ';
            }

            if(campaignMemberType == 'Family') {
                query += ' AND Family_Attendance__c <> NULL ';
            }

            listHr = Database.query(query);

        }
        
        if (listHR != null && listHr.size() > 0){
            
        	if(listHr[0].Family_Attendance__c != null) {
                     testRelatedID =  listHr[0].Family_Attendance__c;
                }
                else {
                    testRelatedID =  listHr[0].Volunteer_Attendance__c;
                }
                testWhoID = listHr[0].ContactId;
            }
           
        
    
        if (fEmailContactsOnlyOnce) {       
            set<ID> setContactId = new set<ID>();
            for (CampaignMember ta : listHr) {
                if(String.isNotEmpty(ta.ContactId)) {
                    setContactId.add(ta.ContactId);
                }
            }
            NumberOfContacts = setContactId.size();
          
        } else {
            NumberOfContacts = (listHR != null ? listHr.size() : 0);
        }           
        return null;
    }

    // action method to send the email
    public PageReference SendMail() {
    
        // do our validation
        if (numberOfContacts == 0) {        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No valid Contacts selected.')); 
            return null; 
        }
        
        if (templateId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No valid Email Template selected.')); 
            return null;            
        }
        
        try {
            list<Messaging.SingleEmailMessage> listEmail = new list<Messaging.SingleEmailMessage>();
            
            string strSoql = 'select Id, ContactId, Contact.Email, CampaignId, Status,Volunteer_Attendance__c, Family_Attendance__c from CampaignMember where ' + 
                            (!String.isBlank(trStatus) ? ' Status = \'' + trStatus + '\' and ' : '') +
                                ' Contact.Email != null ';          
            //DJA 29/11/2016 Added Campaign Member Type Filter 
            if(campaignMemberType == 'Volunteer') {
                strSoql += ' AND Volunteer_Attendance__c <> NULL AND Volunteer_Attendance__r.Registration_Type__c <> NULL AND Volunteer_Attendance__r.Registration_Type__r.RecordType.DeveloperName <> \'Corporate_Volunteer\' ';
            }
            
            if(campaignMemberType == 'Corporate Volunteer') {
                strSoql += ' AND Volunteer_Attendance__c <> NULL AND Volunteer_Attendance__r.Registration_Type__c <> NULL AND Volunteer_Attendance__r.Registration_Type__r.RecordType.DeveloperName = \'Corporate_Volunteer\' ';
            }

            if(campaignMemberType == 'Family') {
                strSoql += ' AND Family_Attendance__c <> NULL ';
            }
            
            if (campaignId != null) {
                strSoql += ' and CampaignId = :campaignId '; // don't use formula field which is text!      
            }   
           strSoql += ' order by CreatedDate LIMIT 75';        
            
                
            // to keep track of unique contacts
            set<ID> setContactId = new set<ID>();
            List<CampaignMember> updateCMs = new List<CampaignMember>();
            
            for (CampaignMember hr : database.query(strSoql)) {
                if (!fEmailContactsOnlyOnce || setContactId.add(hr.ContactId)) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(hr.ContactId);
                        
                   string whatId;
                     //DJA 4/7/2017 Change to using volunteer or family attendance as the what object for email 
/*                     if (templateObject == 'Campaign') {
                        whatId = hr.CampaignId;
                    }*/
                    whatId = hr.Id;

                    //string whatid;
                    if (hr.Volunteer_Attendance__c <> NULL) {
                      whatId =  hr.Volunteer_Attendance__c; 
                    }
                    if (hr.Family_Attendance__c <> NULL) {
                        whatId = hr.Family_Attendance__c;
                    }
                    
                    mail.setwhatid(whatId);
                    
                    mail.setSaveAsActivity(fLogActivity);
                    if (fromEmailId != null) {
                        mail.setOrgWideEmailAddressId(fromEmailId);
                    }
                    mail.setTemplateID(templateId); 
                    System.debug('mail: '+ mail);
                    listEmail.add(mail);
                }                   
                
                if(updateCmStatus && String.isNotEmpty(cmStatus)) {
                    hr.Status = cmStatus;
                    updateCMs.add(hr);
                }
            }                           
			
			Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE Id  IN :setContactId]);                           
                        
            // send the email and return
            if (listEmail.size() > 0) {
                list<Messaging.SendEmailResult> listSER;
                listSER = Messaging.sendEmail(listEmail, false);
                
                // report problems
                integer cSuccess = 0;
				for (Messaging.SendEmailResult ser : listSER) {
                    if (ser.isSuccess()) {
                        cSuccess++;
                    } else {
                        list<Messaging.SendEmailError> listSEE = ser.getErrors();
                        System.debug(listSee);
                        for (Messaging.SendEmailError see : listSEE) {
                            ID objId = see.getTargetObjectId();
                            if (objId == null) {
                                // see if we can parse it out of the error string.
                                string strErr = see.getMessage();
                                integer ich = strErr.lastIndexOf(' for id : ');
                                if (ich > = 0) {
                                    objId = strErr.substring(ich + 10);
                                }
                            }
            
                            string strDetails = '';
                            if (conMap.containsKey(objId)) 
                                strDetails = ' ' + conMap.get(objId).Name + ' (' + conMap.get(objId).Email + ') '; 
                            // special case logging Activity failing
                            if (see.getStatusCode() == System.StatusCode.FIELD_INTEGRITY_EXCEPTION && fLogActivity)
                                strDetails += ' ' + 'Failed to log activity to Contact.'; 

                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, see.getStatusCode() + ': ' + see.getMessage() + strDetails));
                        }
                    }
                }
                
                if(updateCMs.size() > 0) {
                    try {
                        update updateCMs;
                    } catch(DmlException ex) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to update Campaign Members: ' + ex.getMessage()));
                    }
                }
                
                if (cSuccess > 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Successfully Mass emailed Attendees.' + ' ' + cSuccess));  
                    
                    System.debug('Successes: '+cSuccess);
                }
                    
                if (listSER.size() > 0)  
                    return null;  // stay on the page
            }
            return Cancel(); // this will take us back to our calling page.
                        
        } catch (exception ex) {
            ApexPages.addMessages(ex);   
            return null;            
        } 
    }
    
    // action method that user wants to close this page
    public PageReference Cancel() {
        string strURL = ApexPages.currentPage().getParameters().get('retURL');
        if (strURL == null || strURL == '') strURL = '/';
        PageReference p = new PageReference(strURL);
        p.setRedirect(true);
        return p;
    }
    
}