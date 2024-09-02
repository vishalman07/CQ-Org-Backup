public class SendSelectedEmailController {
    public Id camId {get;set;}
    public Map<Id, Family_Attendance__c> fas{get;set;}
    //public Map<Id, Family_Member_Attendance__c> fmas{get;set;}
    public Map<Id, Volunteer_Attendance__c> vas{get;set;}
    public integer numberOfContacts { get; set; }

    public Map<Id, Boolean> faEmail{get;set;}
    public Map<Id, Boolean> vaEmail{get;set;}

    public set<ID> emailAccounts{get;set;}

    public String markBy{get;set;}
    public Id attendId{get;set;}

    public ID templateId { get; set; }
    public ID fromEmailId { get; set; }


    public SendSelectedEmailController(ApexPages.StandardController sc) {

        camId = sc.getId();

        setAttendeds();
        markBy = 'Family';

    }
    public void setAttendeds() {

        loadAttendees();
        faEmail = new Map<Id, Boolean>();
        vaEmail = new Map<Id, Boolean>();
        emailAccounts = new set<id>();
        NumberOfContacts =0;
        if(fas != null) {
            for (Id fasId : fas.keySet()){
                if(fas.get(fasId).Campaign_Members__r.size() == 0){
                    fas.remove(fasId);
                }
            }

            for(Id key : fas.keySet()) {
                faEmail.put(key,False);
            }
        }

        if(vas != null) {
            for (Id vasId : vas.keySet()){
                if(vas.get(vasId).Campaign_Members__r.size() == 0){
                    vas.remove(vasId);
                }
            }

            for(Id key : vas.keySet()) {
                vaEmail.put(key, False);

            }
        }

    }
    private void loadAttendees() {

        if(markBy == 'Volunteer' ) {
            vas = new Map<Id, Volunteer_Attendance__c>([SELECT Id, Attendance__c, Volunteer__r.FirstName, Volunteer__r.LastName, Volunteer__r.MailingStreet, Volunteer__r.MailingCity, Volunteer__r.MailingState, Volunteer__r.MailingPostalCode, Volunteer_Rating__c, Participation_role__C , (select contact__r.firstname from Companion_Children__r),  (SELECT Match_Up_Sent__c from campaign_members__R limit 1)
            FROM Volunteer_Attendance__c
            WHERE Event__c = :camId
            AND (Attendance__c = 'Accepted' OR Attendance__c = 'Attended')]);
        } else {
            fas = new Map<Id, Family_Attendance__c>([SELECT Id,  FA_00000__c, (SELECT Match_Up_Sent__c from Campaign_Members__R limit 1) , Family__r.Name, Family__r.BillingStreet, Family__r.BillingCity, Family__r.BillingState, Family__r.BillingPostalCode, Family__r.npe01__One2OneContact__c , (SELECT Id, Contact__r.FirstName, Family_Member_Attendance__c.Companion__c, Family_Member_Attendance__c.Companion__r.Volunteer__r.FirstName FROM Family_Member_Attendance__r WHERE (Attendance__c = 'Accepted' OR Attendance__c = 'Attended') ) FROM Family_Attendance__c WHERE Event__c = :camId AND (FA_00000__c = 'Accepted' OR FA_00000__c = 'Attended')]);
        }


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
    public void updateEmailList() {

        System.debug('markBy: ' + markBy);


        if(markBy == 'Family' && fas != null && fas.containsKey(attendId)) {
            Family_Attendance__c fa = fas.get(attendId);

            if (faemail.get(attendId)) {

                emailAccounts.add(fa.Family__r.npe01__One2OneContact__c);

            }
            else
            {
                emailAccounts.remove(fa.Family__r.npe01__One2OneContact__c);
            }

        }
        else if(vas != null && vas.containsKey(attendId)) {
            Volunteer_Attendance__c va = vas.get(attendId);

            if (vaemail.get(attendId)) {
                emailAccounts.add(va.Volunteer__c);
            }
            else
            {
                emailAccounts.remove(va.Volunteer__c);
            }
        }

        NumberOfContacts = (emailAccounts != null ? emailAccounts.size() : 0);

    }
    public PageReference SendMail() {

        // do our validation
        if (numberOfContacts == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No valid Contacts selected.'));
            return null;
        }
        if (markby == 'Family') {
            EmailTemplate etemp  =  [SELECT Id from EmailTemplate where developername ='Child_Match_Up_Letter' LIMIT 1];
            templateid = etemp.id;
        }
        else  {
            EmailTemplate etemp  =  [SELECT Id from EmailTemplate where developername ='Vol_Matchup_Letter' LIMIT 1];

            templateid = etemp.id;
        }

        if (templateId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No valid Email Template selected.'));
            return null;
        }

        try {
            list<Messaging.SingleEmailMessage> listEmail = new list<Messaging.SingleEmailMessage>();

            string strSoql = 'select Id, ContactId,  Match_Up_Sent__c, Contact.Email, CampaignId, Status,Volunteer_Attendance__c, Family_Attendance__c from CampaignMember where  Contact.Email != null ';
            //DJA 29/11/2016 Added Campaign Member Type Filter
            //strSoql += 'and (status = \'Acceptance to be Sent\' or status = \'Acceptance Sent\' or status = \'Vol - Acceptance to be Sent\' or status = \'Vol - Acceptance Sent\' )';
            if(markBy == 'Family') {
                strSoql += ' AND Family_Attendance__c <> NULL ';
            }
            else {
                strSoql += ' AND Volunteer_Attendance__c <> NULL ';
            }

            if (camId != null) {
                strSoql += ' and CampaignId = :camId'; // don't use formula field which is text!
            }

            //Create local emailid set as private set was causing issues
            set<ID> emailID = new set<ID>();

            for (ID i : emailAccounts) {

                emailID.add(i);
            }

            emailAccounts.clear();
            NumberOfContacts =0;
            strSoql += ' and contactId IN :emailID';

            strSoql += ' order by CreatedDate LIMIT 200';
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Email Accounts' + emailAccounts));

            // to keep track of unique contacts
            set<ID> setContactId = new set<ID>();
            List<CampaignMember> updateCMs = new List<CampaignMember>();


            for (CampaignMember hr : database.query(strSoql)) {
                //send only once
                //if (setContactId.add(hr.ContactId) == true) {

                if (setContactId.add(hr.ContactId)) {

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

                    mail.setSaveAsActivity(true);

                    if (fromEmailId != null) {
                        mail.setOrgWideEmailAddressId(fromEmailId);
                    }

                    mail.setTemplateID(templateId);
                    System.debug('mail: '+ mail);

                    listEmail.add(mail);

                    hr.Match_Up_Sent__c = True;
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
                            if (see.getStatusCode() == System.StatusCode.FIELD_INTEGRITY_EXCEPTION && true)
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
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Successfully Mass emailed Attendees.  Please click refresh on your browser to see updated records with Email Match Up Sent.' + ' ' + cSuccess));
                    System.debug('Successes: '+cSuccess);
                }

                if (listSER.size() > 0)
                    return null;  // stay on the page
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No one selected: '));
            return null;
            //return Cancel(); // this will take us back to our calling page.

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