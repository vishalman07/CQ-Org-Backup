@isTest
public class SendBulkEmailControllerTest {
    
    //==================== TEST METHOD(s) ======================================
    public static testmethod void TestSendEmails() {
        
        // set up intial test data
        Account acc = new Account(name='Individual Test Account');
        insert acc;
        Contact con = new Contact(Lastname='Testy', Email='testy@foo.com', AccountId=acc.Id);
        insert con;
        Campaign cmp = new Campaign(name='Test Campaign', IsActive=true);
        insert cmp;
        CampaignMember cmpmem = new CampaignMember(ContactId = con.Id, CampaignId = cmp.Id);
        insert cmpmem;
        
        //point to our VF page
        PageReference p = Page.SendBulkEmail;
        Test.setCurrentPageReference(p);
        	
        ApexPages.currentPage().getParameters().put('campaignId', cmp.id);

        SendBulkEmailController ctrl = new SendBulkEmailController();
        
        //instantiate the controller for this opp
        System.Assert(ctrl.getlistSOTemplates().size() > 1);
        System.Assert(ctrl.getlistSOFromEmails().size() >= 1);
        
        //load email folders
        ctrl.getlistEmailFolders();

        //get campaign member statuses
        System.assert(ctrl.getCmStatuses().size() > 0);
        System.assert(ctrl.getTrStatuses().size() > 0);
        
        // load a template
        EmailTemplate et = [select Id from EmailTemplate LIMIT 1];
        ctrl.templateId = et.Id;
        ctrl.LoadEmailTemplate();
        //System.assert(ctrl.strSubject != null);
        //System.assert(ctrl.strMessage != null);
        
        // find contacts
        //ctrl.hourStatus.Status__c = 'Confirmed';
        ctrl.StatusChanged();
        //System.assertEquals(1, ctrl.numberOfContacts);
        
        PageReference p1 = ctrl.Cancel();
        system.assert(p1 != null);
        
        ctrl.updateCMStatus = true;
        ctrl.cmStatus = 'Sent';
        ctrl.fLogActivity = false; // upgraders might not have Activities on for Jobs and Shifts
        PageReference p2 = ctrl.SendMail();
        system.assertEquals(null, p2);
        
        // misc 
        system.assert(ctrl.OpenEmailTemplateFolder() != null);
        system.assert(ctrl.EditEmailTemplate() != null);
        
        // test no template
        ctrl.templateId = null;
        ctrl.LoadEmailTemplate();
        System.assert(ctrl.strSubject == null);
        System.assert(ctrl.strMessage == null);
        system.assertEquals(null, ctrl.SendMail());
        
        // test no contacts found
        ctrl.fEmailContactsOnlyOnce = true;
        ctrl.StatusChanged();
        System.assertEquals(1, ctrl.numberOfContacts);
        system.assertEquals(null, ctrl.SendMail()); 	
        
    }
    
}