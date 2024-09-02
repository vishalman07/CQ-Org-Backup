/********************************************************************************************
* @Name         Good2GiveBatch
* @Author       Amit Yadav
* @Date         08/23/2023
* @Description  This batch class is use in csvUploadcontroller Class for uploading "Good2Give" file data.  
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         08/23/2023         Initial Creation                                                      
******************************************************************************************* */
public class Good2GiveBatch implements Database.Batchable<CsvUploadController.Good2giveWrapper>,Database.stateful {
    
    private List<CsvUploadController.Good2giveWrapper> g2gList;
    private Integer no_Opp = 0;
    private Integer no_camp = 0;
    private Integer no_con = 0;
    private CsvUploadLog__c log;
    public Good2GiveBatch(List<CsvUploadController.Good2giveWrapper> g2gList , CsvUploadLog__c logObj) {
        List<CsvUploadController.Good2giveWrapper> g2gListobj = new List<CsvUploadController.Good2giveWrapper>(g2gList);
        this.g2gList = g2gListobj;
        this.log = logObj;
    }
    //Fetching Parent Campaign Record
    public List<Campaign> parentCamp = [Select Id, Name, Funraisin_Id__c From campaign Where Funraisin_Id__c =: Label.Good2give Limit 1];
    
    public Iterable<CsvUploadController.Good2giveWrapper> start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute   
        return g2gList;
    }
    
    public void execute(Database.BatchableContext BC, List<CsvUploadController.Good2giveWrapper> g2gList) {
        Map<String,Account> accNameAndAccObjectOldMap = new Map<String,Account>();
        Map<String,Contact> conNameAndConObjectOldMap = new Map<String,Contact>();
        Map<String,Campaign> campNameAndCampObjectOldMap = new Map<String,Campaign>();
        List<String> campaignList = new List<String>();
        List<String> contactEmailList = new List<String>();
        List<String> accountEmailList = new List<String>();
        List<CsvUploadSubLog__c> subLogList = new List<CsvUploadSubLog__c>();
        //Fetching old records of campaign, contact , account 
        for(CsvUploadController.Good2giveWrapper g2g : g2gList){
            if(!String.isBlank(g2g.employer_Name)){
              campaignList.add('g2g:' + g2g.employer_Name.deleteWhitespace().toLowerCase());
                if(!String.isBlank(g2g.donor_Email) && !String.isBlank(g2g.donor_Lastname)){
                    contactEmailList.add(g2g.donor_Email.toLowerCase());
                    accountEmailList.add(g2g.donor_Email.toLowerCase());
                }
            }            
        }
        Map<Integer, String> indexTransactionId = new Map<Integer,String>();
        Integer indexNumber = 0;
        //get index for pay transaction id in the List paypalList
		for(CsvUploadController.Good2giveWrapper g2g : g2gList){
            indexTransactionId.put(indexNumber, g2g.donation_Confirmation_Number);
            indexNumber++;
        }
        for(Campaign camp : [Select Id,Name,Funraisin_Id__c From Campaign Where Funraisin_Id__c IN: campaignList]){
            if(!campNameAndCampObjectOldMap.containskey(camp.Funraisin_Id__c))
                campNameAndCampObjectOldMap.put(camp.Funraisin_Id__c , camp);
        }
        for(Contact con : [Select Id,Lastname,Email,AccountId From Contact Where Email IN : contactEmailList]){
            if(!conNameAndConObjectOldMap.containskey(con.Email))
                conNameAndConObjectOldMap.put(con.Email , con);
        }
        for(Account ac : [Select Id,Name,Email__c From Account Where Email__c IN : accountEmailList]){
            if(!accNameAndAccObjectOldMap.containskey(ac.Email__c))
                accNameAndAccObjectOldMap.put(ac.Email__c , ac);
        }
        Map<String,Account> accNameAndAccObjectMap = new Map<String,Account>();
        Map<String,Contact> conNameAndConObjectMap = new Map<String,Contact>();
        Map<String,Campaign> campNameAndCampObjectMap = new Map<String,Campaign>();
        Map<String,Opportunity> oppNameAndOppObjectMap = new Map<String,Opportunity>();
        for(CsvUploadController.Good2giveWrapper g2g : g2gList){
            if(!String.isBlank(g2g.employer_Name)){
               String campaignKey = 'g2g:' + g2g.employer_Name.deleteWhitespace().toLowerCase();
                if(!campNameAndCampObjectMap.containsKey(campaignKey) && !campNameAndCampObjectOldMap.containsKey(campaignKey)){
                    campaign camp = new campaign();
                    camp.Name = parentCamp[0].Name + ': ' + g2g.employer_Name;
                    camp.Funraisin_Id__c = campaignKey;
                    camp.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
                    camp.ParentId = parentCamp[0].id;
                    campNameAndCampObjectMap.put(campaignKey , camp);
                }
                if(!String.isBlank(g2g.donor_Lastname) && !String.isBlank(g2g.donor_Email)){
                    if(!accNameAndAccObjectMap.containsKey(g2g.donor_Email.toLowerCase()) && !accNameAndAccObjectOldMap.containsKey(g2g.donor_Email.toLowerCase())){
                        Account ac = new Account();
                        ac.Name =  g2g.donor_Lastname +' Household';
                        ac.Email__c = g2g.donor_Email;
                        ac.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Family').getRecordTypeId();
                        accNameAndAccObjectMap.put(g2g.donor_Email , ac);
                    }
                }
                else {
                    if(!accNameAndAccObjectMap.containsKey(g2g.donor_Email.toLowerCase()) && !accNameAndAccObjectOldMap.containsKey(g2g.donor_Email.toLowerCase())){
                        Account ac = new Account();
                        ac.Name = g2g.employer_Name;
                        ac.Email__c = g2g.donor_Email;
                        ac.RecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organisation').getRecordTypeId();
                        accNameAndAccObjectMap.put(g2g.donor_Email.toLowerCase() , ac);
                    }                                    
                }
            }
        }
        
        if(campNameAndCampObjectMap.values()  != null){
            //Insert Campaign object
            // insert campNameAndCampObjectMap.values();
             Integer h = 0;
            Database.SaveResult[] insertResults = Database.insert(campNameAndCampObjectMap.values(), false);
            for (Database.SaveResult sr : insertResults) {
                if (sr.isSuccess()) {
                    // This record was inserted successfully
                    no_camp++;
                } 
				else {
                        // Operation failed, so get all errors                
                            CsvUploadSubLog__c subLogRec = new CsvUploadSubLog__c();
                            subLogRec.Object_Name__c = 'Campaign';
                            subLogRec.CsvUploadLog__c = log.Id;
                            Database.Error erMessage = sr.getErrors().get(0);
                            subLogRec.Error_Message__c = String.valueOf(erMessage.getStatusCode());
                            subLogRec.transaction_Id__c = indexTransactionId.get(h);
                            subLogList.add(subLogRec);
                        
                    }
            }
        }
        if(accNameAndAccObjectMap.values()  != null){
            //Insert Account Object
            insert accNameAndAccObjectMap.values();
        }
        
        for(CsvUploadController.Good2giveWrapper g2g : g2gList){
            if(!String.isBlank(g2g.donor_Lastname) && !String.isBlank(g2g.donor_Email) ){
                if(!conNameAndConObjectMap.containsKey(g2g.donor_Email.toLowerCase()) && !conNameAndConObjectOldMap.containsKey(g2g.donor_Email.toLowerCase()) && !accNameAndAccObjectOldMap.containsKey(g2g.donor_Email.toLowerCase())){
                    Contact con = new Contact();
                    con.LastName = g2g.donor_Lastname;
                    con.FirstName = g2g.donor_Firstname;
                    if(accNameAndAccObjectMap.containsKey(g2g.donor_Email.toLowerCase())){
                        con.AccountId = accNameAndAccObjectMap.get(g2g.donor_Email.toLowerCase()).Id;
                    }                
                    con.Email = g2g.donor_Email;
                    con.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
                    conNameAndConObjectMap.put(con.Email,con);
                }                
            }
        }
        if(conNameAndConObjectMap.values() != null){
            System.debug('Insert Contact =====>');
            System.debug(conNameAndConObjectMap);
            //Insert Contact Object            
                //insert conNameAndConObjectMap.values();
                Integer j=0;
                Database.SaveResult[] insertResults = Database.insert(conNameAndConObjectMap.values(), false);
                for (Database.SaveResult sr : insertResults) {
                    if (sr.isSuccess()) {
                        // This record was inserted successfully
                        no_con++;
                    }
                    else {
                        // Operation failed, so get all errors                
                        CsvUploadSubLog__c subLogRec = new CsvUploadSubLog__c();
                        subLogRec.Object_Name__c = 'Contact';
                        subLogRec.CsvUploadLog__c = log.Id;
                        Database.Error erMessage = sr.getErrors().get(0);
                        subLogRec.Error_Message__c = String.valueOf(erMessage.getStatusCode());
                        subLogRec.transaction_Id__c = indexTransactionId.get(j);
                        subLogList.add(subLogRec);
                        
                    }  
            }
        }
        for(CsvUploadController.Good2giveWrapper g2g : g2gList){
            if(!String.isBlank(g2g.employer_Name)){
                if(!String.isBlank(g2g.donor_Lastname) && !String.isBlank(g2g.donor_Email)){
                    
                    Opportunity opp = new Opportunity();
                    opp.Name = g2g.donor_FirstName +' '+ g2g.donor_LastName + ' Donation ' + g2g.donation_Date +' '+ parentCamp[0].Name + ': ' + g2g.employer_Name;
                    opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
                    opp.StageName = 'Closed Won';
                    String amount = g2g.donation_Amount.substring(1);
                    opp.Amount = decimal.valueOf(amount);
                    String donationDate = g2g.donation_date;
                    String newDate = donationDate.substring(0,2)+'/'+donationDate.substring(3,5)+'/'+donationDate.substring(6);
                    Date closedDate = date.parse(newDate);
                    opp.CloseDate = closedDate ;
                    if(conNameAndConObjectMap.containsKey(g2g.donor_Email.toLowerCase())){
                        opp.ContactId = conNameAndConObjectMap.get(g2g.donor_Email.toLowerCase()).Id;
                        opp.AccountId = conNameAndConObjectMap.get(g2g.donor_Email.toLowerCase()).AccountId;
                    }
                    else if(conNameAndConObjectOldMap.containsKey(g2g.donor_Email.toLowerCase())){
                        opp.ContactId = conNameAndConObjectOldMap.get(g2g.donor_Email.toLowerCase()).Id;
                        opp.AccountId = conNameAndConObjectOldMap.get(g2g.donor_Email.toLowerCase()).AccountId;
                    }
                    if(campNameAndCampObjectMap.containsKey( 'g2g:'+g2g.employer_Name.deleteWhitespace().toLowerCase())){
                        opp.CampaignId = campNameAndCampObjectMap.get('g2g:'+g2g.employer_Name.deleteWhitespace().toLowerCase()).id;
                    }
                    else if(campNameAndCampObjectOldMap.containsKey('g2g:'+g2g.employer_Name.deleteWhitespace().toLowerCase())){
                        opp.CampaignId = campNameAndCampObjectOldMap.get('g2g:'+g2g.employer_Name.deleteWhitespace().toLowerCase()).id;
                    }
                    opp.Funraisin_Id__c = 'g2g:' + g2g.donation_Confirmation_Number;
                    opp.Receipt_Number__c = g2g.donation_Confirmation_Number;                    
                    oppNameAndOppObjectMap.put(opp.Funraisin_Id__c , opp);
                }
                else {
                    Opportunity opp = new Opportunity();
                    opp.Name = g2g.employer_Name +' '+ g2g.donation_Amount +' '+ g2g.donation_Date;
                    opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
                    opp.StageName = 'Closed Won';
                    String amount = g2g.donation_Amount.substring(1);
                    opp.Amount = decimal.valueOf(amount);
                    String donationDate = g2g.donation_Date;
                    String newDate = donationDate.substring(0,2)+'/'+donationDate.substring(3,5)+'/'+donationDate.substring(6);
                    Date closedDate = date.parse(newDate);
                    opp.CloseDate = closedDate;
                    if(accNameAndAccObjectMap.containsKey(g2g.donor_Email.toLowerCase())){
                        opp.AccountId = accNameAndAccObjectMap.get(g2g.donor_Email.toLowerCase()).Id;
                    }
                    if(campNameAndCampObjectMap.containsKey( 'g2g:'+g2g.employer_Name.deleteWhitespace().toLowerCase())){
                        opp.CampaignId = campNameAndCampObjectMap.get('g2g:'+g2g.employer_Name.deleteWhitespace().toLowerCase()).id;
                    }
                    else if(campNameAndCampObjectOldMap.containsKey( 'g2g:'+g2g.employer_Name.deleteWhitespace().toLowerCase())){
                        opp.CampaignId = campNameAndCampObjectOldMap.get('g2g:'+g2g.employer_Name.deleteWhitespace().toLowerCase()).id;
                    }
                    opp.Funraisin_Id__c = 'g2g:' + g2g.donation_Confirmation_Number;
                    opp.Receipt_Number__c = g2g.donation_Confirmation_Number;
                    oppNameAndOppObjectMap.put(opp.Funraisin_Id__c , opp);
                }
            }
        }
        
        if(oppNameAndOppObjectMap.values() != null){
            //Inserting Opportunity
            //insert oppNameAndOppObjectMap.values();
            Integer k = 0;
            Database.SaveResult[] insertResults = Database.insert(oppNameAndOppObjectMap.values(), false);
            for (Database.SaveResult sr : insertResults) {
                if (sr.isSuccess()) {
                    // This record was inserted successfully
                    no_opp++;
                }
                else {
                    // Operation failed, so get all errors                
                    CsvUploadSubLog__c subLogRec = new CsvUploadSubLog__c();
                    subLogRec.Object_Name__c = 'Campaign';
                    subLogRec.CsvUploadLog__c = log.Id;
                    Database.Error erMessage = sr.getErrors().get(0);
                    subLogRec.Error_Message__c = String.valueOf(erMessage.getStatusCode());
                    subLogRec.transaction_Id__c = indexTransactionId.get(k);
                    subLogList.add(subLogRec);
                    
                }
            } 
        }
        
        if(subLogList.size()>0){
            //Insert sub logs
            insert subLogList;
        } 
        List<npe01__OppPayment__c> updatePayement = new List<npe01__OppPayment__c>();
        Map<String , npe01__OppPayment__c> updatePaymentMap = new Map<String, npe01__OppPayment__c>();
        List<npe01__OppPayment__c> paymentList = [Select Id, npe01__Opportunity__c, npe01__Opportunity__r.Funraisin_Id__c , npsp_plus__Payment_Fee__c , Gateway_Payout_Id__c , Gateway_Payout_Date__c ,npsp_plus__Payment_Net_Amount__c , npe01__Payment_Amount__c From npe01__OppPayment__c Where npe01__Opportunity__c IN : oppNameAndOppObjectMap.values()];
        for(npe01__OppPayment__c payment : paymentList){
            if(!updatePaymentMap.containsKey(payment.npe01__Opportunity__r.Funraisin_Id__c)){
                updatePaymentMap.put(payment.npe01__Opportunity__r.Funraisin_Id__c , payment);
            }
        }
        for(CsvUploadController.Good2giveWrapper g2g: g2gList){
            system.debug('inside for line 269');
    if(updatePaymentMap.containsKey('g2g:'+ g2g.donation_Confirmation_Number)){
        system.debug('inside if');
        Date payoutDate;
        if(g2g.payout_Date.contains('-')){
			
             List<String> dateParts = g2g.payout_Date.split('-');
             String formattedDate = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
			 payoutDate = date.valueof(formattedDate);
             System.debug('payoutDate 278'+payoutDate);
            
        } else if(g2g.payout_Date.contains('/')){           
				payoutDate = date.parse(g2g.payout_Date);
                system.debug('payoutDate 282'+payoutDate);            
        }
        updatePaymentMap.get('g2g:'+ g2g.donation_Confirmation_Number).Gateway_Payout_Date__c = date.valueOf(payoutDate);
		System.debug('--updatePayement Line 285--'+ updatePaymentMap);
        updatePayement.add(updatePaymentMap.get('g2g:'+ g2g.donation_Confirmation_Number));
        System.debug('--updatePayement Line 326--'+ updatePayement);
        update updatePayement;
    }
	}
   
    }
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
        log.Campaign_Created__c = String.valueOf(no_camp);
        log.Contact_created__c = String.valueOf(no_con);
        log.Opportunities_created__c =String.valueOf(no_opp);
        update log;
    }
}