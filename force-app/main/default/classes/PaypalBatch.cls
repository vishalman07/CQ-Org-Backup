/********************************************************************************************
* @Name         PaypalBatch
* @Author       Amit Yadav
* @Date         08/23/2023
* @Description  This batch class is use in csvUploadcontroller Class for uploading "paypal giving fund" file data.  
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         08/23/2023         Initial Creation

* Version          Developer          Date               Description
*
*  1.1             Amit Yadav         11/06/2023         Addition of CsvUploadSubLogObject                                                      
******************************************************************************************* */
public class PaypalBatch implements Database.Batchable<CsvUploadController.PaypalWrapper>,Database.stateful {
    
    private List<CsvUploadController.PaypalWrapper> paypalList;
    private Integer no_Opp = 0;
    private Integer no_camp = 0;
    private Integer no_con = 0;
    private CsvUploadLog__c log;
    public PayPalBatch(List<CsvUploadController.PaypalWrapper> paypalList , CsvUploadLog__c logObj) {
        List<CsvUploadController.PaypalWrapper> paypalListobj = new List<CsvUploadController.PaypalWrapper>(paypalList);
        this.paypalList = paypalListobj;
        this.log = logObj;
    }
    public Iterable<CsvUploadController.PaypalWrapper> start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute   
        return paypalList;
    }
    
    public void execute(Database.BatchableContext BC, List<CsvUploadController.PaypalWrapper> paypalList) {
        //Fetching parent campaign for Paypal
        List<String> funraisinIds = new List<String>();
        funraisinIds.add(Label.PaypalParentFacebook);
        funraisinIds.add(Label.PaypalParentGoFundMe);
        funraisinIds.add(Label.PaypalParentAppAndWeb);
        funraisinIds.add(Label.PaypalParentGive);
        funraisinIds.add(Label.Paypal_Parent);
        List<Campaign> parentCampList = [Select Id,Name,Funraisin_Id__c From Campaign Where Funraisin_Id__c In : funraisinIds];
        Map<String,Campaign> parentcampNameByObjectMap = new Map<String,Campaign>();
        if(parentCampList.size() > 0){
            for(Campaign camp : parentCampList){
                parentcampNameByObjectMap.put(camp.Funraisin_Id__c,camp);
            }
        }
        
        Map<Integer, String> indexTransactionId = new Map<Integer,String>();
        Integer indexNumber = 0;
        //get index for pay transaction id in the List paypalList
        for(CsvUploadController.PaypalWrapper pay : paypalList){
            indexTransactionId.put(indexNumber, pay.transaction_ID);
            indexNumber++;
        }
        
        List<String> listOfCampaignIds = new List<String>();
        //Fetching old Campaign and Contact records and store in Map 
        Map<String,Campaign> oldCampaignByFundIdMap = new Map<String,Campaign>();
        Map<String,Contact> conNameAndConObjectOldMap = new Map<String,Contact>();
        List<String> contactEmailList = new List<String>();
        Map<String,Account> accEmailAndAccObjectMap = new Map<String,Account>();
        List<CsvUploadSubLog__c> subLogList = new List<CsvUploadSubLog__c>();
        for(CsvUploadController.PaypalWrapper pay : paypalList){
            if(!String.isBlank(pay.reference_Information)){
                if(pay.reference_Information.contains(':')){
                    Integer index = pay.reference_Information.indexOf(':');
                    String funraisinId = pay.reference_Information.substring(0,index);
                    listOfCampaignIds.add('ppgf:'+funraisinId.deleteWhitespace().toLowerCase());
                }
                else{
                    String funraisinId = pay.reference_Information.deleteWhitespace().toLowerCase();
                    listOfCampaignIds.add('ppgf:'+funraisinId); 
                }
            }
            if(!String.isBlank(pay.donor_Email) && !String.isBlank(pay.donor_Last_Name)){
                Account ac = new Account();
                ac.Name =  pay.donor_Last_Name +' Household';
                ac.Email__c = pay.donor_Email;
                ac.recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Family').getRecordTypeId();
                accEmailAndAccObjectMap.put(pay.donor_Email , ac);
                contactEmailList.add(pay.donor_Email);
            }
        }
        if(accEmailAndAccObjectMap.values()  != null){
            //Insert Account
            Insert accEmailAndAccObjectMap.values();
        }
        if(listOfCampaignIds.size() > 0){
            List<Campaign> oldCampaignList = [Select Id,Funraisin_Id__c,Name From Campaign Where Funraisin_Id__c IN : listOfCampaignIds];
            for(Campaign camp : oldCampaignList){
                if(!oldCampaignByFundIdMap.containskey(camp.Funraisin_Id__c))
                    oldCampaignByFundIdMap.put(camp.Funraisin_Id__c,camp);
            }
        }
        if(contactEmailList.size() > 0){
            for(Contact con : [Select Id,FirstName,Lastname,Email,Name,AccountId From contact Where Email IN : contactEmailList]){
                if(!conNameAndConObjectOldMap.containskey(con.Email.toLowerCase()))
                    conNameAndConObjectOldMap.put(con.Email.toLowerCase() , con);
            }
        }
        Map<String,Contact> conNameAndConObjectMap = new Map<String,Contact>();
        for(CsvUploadController.PaypalWrapper pay : paypalList){
            if(!String.isBlank(pay.donor_Last_Name) && !String.isBlank(pay.donor_Email)){
                if(!conNameAndConObjectMap.containsKey(pay.donor_Email.toLowerCase()) && !conNameAndConObjectOldMap.containsKey(pay.donor_Email.toLowerCase())){
                    //Creating contact and put into Map with conatct Email and object
                    Contact con = new Contact();
                    con.LastName = pay.donor_Last_Name;
                    if(accEmailAndAccObjectMap.containsKey(pay.donor_Email.toLowerCase())){
                        con.AccountId = accEmailAndAccObjectMap.get(pay.donor_Email.toLowerCase()).Id;
                    }
                    con.FirstName = pay.donor_First_Name;
                    con.Email = pay.donor_Email;
                    con.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
                    conNameAndConObjectMap.put(con.Email.toLowerCase(),con);
                }
            }
        }
        if(conNameAndConObjectMap.values() != null){
            Integer h = 0;
            //Inserting Contact object
            //insert conNameAndConObjectMap.values();
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
                    subLogRec.transaction_Id__c = indexTransactionId.get(h);
                    subLogList.add(subLogRec);
                    
                }
                h++;
            }
        }
        Map<String,Campaign> campFunraisinIdByCampMap = new Map<String,Campaign>();
        
        for(CsvUploadController.PaypalWrapper pay : paypalList){
            if(!String.isBlank(pay.program_Name) && !String.isBlank(pay.reference_Information)){
                Integer index ;
                String funraisinId ;
                String campName ;
                if(pay.reference_Information.contains(':')){
                    index = pay.reference_Information.indexOf(':');
                    funraisinId = pay.reference_Information.substring(0,index).deleteWhitespace().toLowerCase();
                    campName = pay.reference_Information.substring(index+1);
                }
                else{
                    funraisinId = pay.reference_Information.deleteWhitespace().toLowerCase();
                    campName = pay.reference_Information;
                }
                if(!campFunraisinIdByCampMap.containsKey('ppgf:'+funraisinId) && !oldCampaignByFundIdMap.containsKey('ppgf:'+funraisinId)){
                    //Creating campaign and put into Map with Funraisin Id
                    Campaign camp = new Campaign();
                    if(pay.program_Name.toLowercase().contains(Label.paypalFacebookProgramName) && parentcampNameByObjectMap.containsKey(Label.PaypalParentFacebook)){
                        String campaignName = parentcampNameByObjectMap.get(Label.PaypalParentFacebook).Name +': '+ campName;
                        if(campaignName.length() > 80){
                            campaignName = campaignname.substring(0,77)+'...';
                        }
                        camp.Name = campaignName;
                        camp.ParentId = parentcampNameByObjectMap.get(Label.PaypalParentFacebook).Id;
                        camp.Funraisin_Id__c = 'ppgf:'+funraisinId;
                        camp.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
                        campFunraisinIdByCampMap.put('ppgf:'+funraisinId , camp);
                    }
                    else if( pay.program_Name.toLowercase().contains(Label.paypalGoFundMeProgramName) && parentcampNameByObjectMap.containsKey(Label.PaypalParentGoFundMe)){
                        String campaignName = parentcampNameByObjectMap.get(Label.PaypalParentGoFundMe).Name +': '+ campName;
                        if(campaignName.length() > 80){
                            campaignName = campaignname.substring(0,77)+'...';
                        }
                        camp.Name = campaignName;
                        camp.ParentId = parentcampNameByObjectMap.get(Label.PaypalParentGoFundMe).Id;
                        camp.Funraisin_Id__c = 'ppgf:'+funraisinId;
                        camp.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
                        campFunraisinIdByCampMap.put('ppgf:'+funraisinId , camp);
                    }
                    else if(parentcampNameByObjectMap.containsKey(Label.Paypal_Parent)){
                        String campaignName = parentcampNameByObjectMap.get(Label.Paypal_Parent).Name +': '+ campName;
                        if(campaignName.length() > 80){
                            campaignName = campaignname.substring(0,77)+'...';
                        }
                        camp.Name = campaignName;
                        camp.ParentId = parentcampNameByObjectMap.get(Label.Paypal_Parent).Id;
                        camp.Funraisin_Id__c = 'ppgf:'+funraisinId;
                        camp.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
                        campFunraisinIdByCampMap.put('ppgf:'+funraisinId, camp);
                    }
                }
            }
        }
        
        if(campFunraisinIdByCampMap.values()  != null){
            
            //Inserting Campaign object
            System.debug('CampaignList==> '+campFunraisinIdByCampMap.values());
            
            Integer i = 0;
            Database.SaveResult[] insertResults = Database.insert(campFunraisinIdByCampMap.values(), false);
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
                    subLogRec.transaction_Id__c = indexTransactionId.get(i);
                    subLogList.add(subLogRec);
                    
                }
                i++;
            }
        }
        //Create Opportunites
        Map<String,Opportunity> oppNameAndOppObjectMap =new Map<String,Opportunity>();
        for(CsvUploadController.PaypalWrapper pay : paypalList){
            String funraisinId ;
            if(!String.isBlank(pay.reference_Information)){
                if(pay.reference_Information.contains(':')){
                    Integer index = pay.reference_Information.indexOf(':');
                    funraisinId = pay.reference_Information.substring(0,index).deleteWhitespace().toLowerCase();
                }
                else{
                    funraisinId = pay.reference_Information.deleteWhitespace().toLowerCase();
                }
                if(pay.program_Name != '' && pay.program_Name != null && !oppNameAndOppObjectMap.containsKey('ppgf:' +funraisinId + pay.donation_date) ){
                    if(!String.isBlank(pay.donor_Email) && !String.isBlank(pay.donor_Last_Name)){
                        Opportunity opp = new Opportunity();
                        if(conNameAndConObjectMap.containsKey(pay.donor_Email.toLowerCase()) && campFunraisinIdByCampMap.containsKey('ppgf:'+funraisinId) ){
                            String oppName = conNameAndConObjectMap.get(pay.donor_Email.toLowerCase()).FirstName+' '+conNameAndConObjectMap.get(pay.donor_Email.toLowerCase()).LastName + ' Donation ' + pay.donation_Date +' '+campFunraisinIdByCampMap.get('ppgf:'+funraisinId).Name ;
                            if(oppName.length() > 120){
                                oppName = oppName.substring(0,117)+'...';
                            }
                            opp.Name = oppName;
                        }
                        else if(conNameAndConObjectOldMap.containsKey(pay.donor_Email.toLowerCase()) && oldCampaignByFundIdMap.containsKey('ppgf:'+funraisinId) ){
                            String oppName = conNameAndConObjectOldMap.get(pay.donor_Email.toLowerCase()).FirstName+' '+conNameAndConObjectOldMap.get(pay.donor_Email.toLowerCase()).LastName + ' Donation ' + pay.donation_Date +' '+oldCampaignByFundIdMap.get('ppgf:'+funraisinId).Name ;
                            if(oppName.length() > 120){
                                oppName = oppName.substring(0,117)+'...';
                            }
                            opp.Name = oppName;
                        }
                        else if(conNameAndConObjectMap.containsKey(pay.donor_Email.toLowerCase()) && oldCampaignByFundIdMap.containsKey('ppgf:'+funraisinId) ){
                            String oppName = conNameAndConObjectMap.get(pay.donor_Email.toLowerCase()).FirstName+' '+ conNameAndConObjectMap.get(pay.donor_Email.toLowerCase()).LastName + ' Donation ' + pay.donation_Date +' '+oldCampaignByFundIdMap.get('ppgf:'+funraisinId).Name ;
                            if(oppName.length() > 120){
                                oppName = oppName.substring(0,117)+'...';
                            }
                            opp.Name = oppName;
                        }
                        else if(conNameAndConObjectOldMap.containsKey(pay.donor_Email.toLowerCase()) && campFunraisinIdByCampMap.containsKey('ppgf:'+funraisinId) ){
                            String oppName = conNameAndConObjectOldMap.get(pay.donor_Email.toLowerCase()).FirstName+' '+conNameAndConObjectOldMap.get(pay.donor_Email.toLowerCase()).LastName + ' Donation ' + pay.donation_Date +' '+campFunraisinIdByCampMap.get('ppgf:'+funraisinId).Name ;
                            if(oppName.length() > 120){
                                oppName = oppName.substring(0,117)+'...';
                            }
                            opp.Name = oppName;
                        }
                        else {
                            String oppName = conNameAndConObjectOldMap.get(pay.donor_Email.toLowerCase()).FirstName+' '+conNameAndConObjectOldMap.get(pay.donor_Email.toLowerCase()).LastName + ' Donation ' + pay.donation_Date +' '+parentcampNameByObjectMap.get(Label.Paypal_Parent).Name ;
                            if(oppName.length() > 120){
                                oppName = oppName.substring(0,117)+'...';
                            }
                            opp.Name = oppName;
                        }
                        opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
                        opp.StageName = 'Closed Won';
                        opp.Amount = decimal.valueOf(pay.net_Amount);
                        if(pay.donation_Date.contains('-')){
                            List<String> dateParts = pay.donation_Date.split('-');
                            String formattedDate = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
                            Date closedDate = date.valueOf(formattedDate);
                            opp.CloseDate = closedDate;
                        }
                        else if(pay.donation_Date.contains('/')){
                            Date closedDate = date.parse(pay.donation_Date);
                            opp.CloseDate = closedDate;  
                        }
                        if(conNameAndConObjectMap.containsKey(pay.donor_Email.toLowerCase())){
                            opp.ContactId = conNameAndConObjectMap.get(pay.donor_Email.toLowerCase()).Id;
                            opp.AccountId = conNameAndConObjectMap.get(pay.donor_Email.toLowerCase()).AccountId;
                        }
                        else if(conNameAndConObjectOldMap.containsKey(pay.donor_Email.toLowerCase())){
                            opp.ContactId = conNameAndConObjectOldMap.get(pay.donor_Email.toLowerCase()).Id;
                            opp.AccountId = conNameAndConObjectOldMap.get(pay.donor_Email.toLowerCase()).AccountId;
                        }
                        if(campFunraisinIdByCampMap.containsKey('ppgf:'+funraisinId)){
                            opp.CampaignId = campFunraisinIdByCampMap.get('ppgf:'+funraisinId).id;
                        }
                        else if(oldCampaignByFundIdMap.containsKey('ppgf:'+funraisinId)){
                            opp.CampaignId = oldCampaignByFundIdMap.get('ppgf:'+funraisinId).id;
                        }
                        else if(parentcampNameByObjectMap.containsKey(Label.Paypal_Parent)){
                            opp.CampaignId = parentcampNameByObjectMap.get(Label.Paypal_Parent).Id;
                        }
                        opp.Funraisin_Id__c = 'ppgf:' +pay.transaction_ID ;
                        opp.Receipt_Number__c = pay.transaction_ID;                    
                        oppNameAndOppObjectMap.put(opp.Funraisin_Id__c , opp);
                    }
                    else {
                        Opportunity opp = new Opportunity();
                        if(campFunraisinIdByCampMap.containsKey('ppgf:'+funraisinId) ){
                            String oppName = pay.net_Amount +' '+ pay.donation_Date+' '+campFunraisinIdByCampMap.get('ppgf:'+funraisinId).Name;
                            if(oppName.length() > 120){
                                oppName = oppName.substring(0,117)+'...';
                            }
                            opp.Name = oppName;
                        }
                        else if(oldCampaignByFundIdMap.containsKey('ppgf:'+funraisinId) ){
                            String oppName = pay.net_Amount +' '+ pay.donation_Date+' '+oldCampaignByFundIdMap.get('ppgf:'+funraisinId).Name;
                            if(oppName.length() > 120){
                                oppName = oppName.substring(0,117)+'...';
                            }
                            opp.Name = oppName;
                        }
                        else if(parentcampNameByObjectMap.containsKey(Label.Paypal_Parent)){
                            String oppName = pay.net_Amount +' '+ pay.donation_Date+' '+parentcampNameByObjectMap.get(Label.Paypal_Parent).Name;
                            if(oppName.length() > 120){
                                oppName = oppName.substring(0,117)+'...';
                            }
                            opp.Name = oppName;
                        }
                        opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
                        opp.StageName = 'Closed Won';
                        opp.Amount = decimal.valueOf(pay.gross_Amount);
                        if(pay.donation_Date.contains('-')){
                            List<String> dateParts = pay.donation_Date.split('-');
                            String formattedDate = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
                            Date closedDate = date.valueOf(formattedDate);
                            opp.CloseDate = closedDate;
                        }
                        else if(pay.donation_Date.contains('/')){
                            Date closedDate = date.parse(pay.donation_Date);
                            opp.CloseDate = closedDate;  
                        }
                        if(campFunraisinIdByCampMap.containsKey('ppgf:'+funraisinId)){
                            opp.CampaignId = campFunraisinIdByCampMap.get('ppgf:'+funraisinId).id;
                        }
                        else if(oldCampaignByFundIdMap.containsKey('ppgf:'+funraisinId)){
                            opp.CampaignId = oldCampaignByFundIdMap.get('ppgf:'+funraisinId).id;
                        }
                        else if(parentcampNameByObjectMap.containsKey(Label.Paypal_Parent)){
                            opp.CampaignId = parentcampNameByObjectMap.get(Label.Paypal_Parent).Id;
                        }
                        opp.Funraisin_Id__c = 'ppgf:'+pay.transaction_ID ;
                        opp.Receipt_Number__c = pay.transaction_ID;
                        oppNameAndOppObjectMap.put(opp.Funraisin_Id__c , opp);
                    }
                }
            }
            else {
                Opportunity opp = new Opportunity();
                if(parentcampNameByObjectMap.containsKey(Label.PaypalParentAppAndWeb) && pay.program_Name.toLowerCase().contains(Label.paypalAppAndWebProgramName)){
                    String oppName = pay.net_Amount +' '+ pay.donation_Date+' '+parentcampNameByObjectMap.get(Label.PaypalParentAppAndWeb).Name;
                    if(oppName.length() > 120){
                        oppName = oppName.substring(0,117)+'...';
                    }
                    opp.Name = oppName;
                }
                else if(parentcampNameByObjectMap.containsKey(Label.PaypalParentGive) && pay.program_Name.toLowerCase().contains(Label.paypalGiveProgramName)){
                    String oppName = pay.net_Amount +' '+ pay.donation_Date+' '+parentcampNameByObjectMap.get(Label.PaypalParentGive).Name;
                    if(oppName.length() > 120){
                        oppName = oppName.substring(0,117)+'...';
                    }
                    opp.Name = oppName;
                }
                else if(parentcampNameByObjectMap.containsKey(Label.Paypal_Parent)){
                    String oppName = pay.net_Amount +' '+ pay.donation_Date+' '+parentcampNameByObjectMap.get(Label.Paypal_Parent).Name;
                    if(oppName.length() > 120){
                        oppName = oppName.substring(0,117)+'...';
                    }
                    opp.Name = oppName;
                }
                opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
                opp.StageName = 'Closed Won';
                opp.Amount = decimal.valueOf(pay.gross_Amount);
                if(pay.donation_Date.contains('-')){
                    List<String> dateParts = pay.donation_Date.split('-');
                    String formattedDate = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
                    Date closedDate = date.valueOf(formattedDate);
                    opp.CloseDate = closedDate;
                }
                else if(pay.donation_Date.contains('/')){
                    Date closedDate = date.parse(pay.donation_Date);
                    opp.CloseDate = closedDate;  
                }
                if(parentcampNameByObjectMap.containsKey(Label.PaypalParentAppAndWeb) && pay.program_Name.toLowerCase().contains(Label.paypalAppAndWebProgramName)){
                    opp.CampaignId = parentcampNameByObjectMap.get(Label.PaypalParentAppAndWeb).id;
                }
                else if(parentcampNameByObjectMap.containsKey(Label.PaypalParentGive) && pay.program_Name.toLowerCase().contains(Label.paypalGiveProgramName)){
                    opp.CampaignId = parentcampNameByObjectMap.get(Label.PaypalParentGive).id;
                }
                else if(parentcampNameByObjectMap.containsKey(Label.Paypal_Parent)){
                    opp.CampaignId = parentcampNameByObjectMap.get(Label.Paypal_Parent).Id;
                }
                opp.Funraisin_Id__c = 'ppgf:'+ pay.transaction_ID ;
                opp.Receipt_Number__c = pay.transaction_ID;
                oppNameAndOppObjectMap.put(opp.Funraisin_Id__c , opp);
            }
        }
        
        
        if(oppNameAndOppObjectMap.values() != null){
            //Inserting Opportunies
            //insert oppNameAndOppObjectMap.values();
            Integer j = 0;
            Database.SaveResult[] insertResults = Database.insert(oppNameAndOppObjectMap.values(), false);
            for (Database.SaveResult sr : insertResults) {
                if (sr.isSuccess()) {
                    // This record was inserted successfully
                    no_opp++;
                }
                else {
                    
                    // Operation failed, so get all errors                
                    
                    CsvUploadSubLog__c subLogRec = new CsvUploadSubLog__c();
                    subLogRec.Object_Name__c = 'Opportunity';
                    subLogRec.CsvUploadLog__c = log.Id;
                    
                    Database.Error erMessage = sr.getErrors().get(0);
                    subLogRec.Error_Message__c = String.valueOf(erMessage.getStatusCode());
                    
                    subLogRec.Transaction_ID__c = indexTransactionId.get(j);
                    subLogList.add(subLogRec);
                    
                }
                j++;
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
        for(CsvUploadController.PaypalWrapper pay : paypalList){
            if(updatePaymentMap.containsKey('ppgf:'+ pay.transaction_ID)){
                updatePaymentMap.get('ppgf:'+ pay.transaction_ID).npe01__Payment_Amount__c = Decimal.valueOf(pay.gross_Amount);
                updatePaymentMap.get('ppgf:'+ pay.transaction_ID).npsp_plus__Payment_Fee__c = Decimal.valueOf(pay.total_Fees);
                
                // Add the following line to map the Gateway Payout ID
        updatePaymentMap.get('ppgf:'+ pay.transaction_ID).Gateway_Payout_Id__c = string.valueOf(pay.gateway_Payout_Id);
       // String payoutDateString = updatePaymentMap.get('ppgf:'+ pay.transaction_ID).(DateFormat.format(Gateway_Payout_Date__c, 'dd/MM/yyyy'));
          /*if(pay.payout_Date.contains('-')){
                    List<String> dateParts = pay.payout_Date.split('-');
                    String formattedDate = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
                    Date closedDate = date.valueOf(formattedDate);
       updatePaymentMap.get('ppgf:'+ pay.transaction_ID).Gateway_Payout_Date__c = date.valueOf(pay.payout_Date);

                } */  
                
        //Date  payoutDate =Date.valueOf(pay.payout_Date);
//Date payoutDate = Date.valueOf(pay.payout_Date); // Convert the String to Date
          
           // string   newDate=  dateParts.substring(0,2)+'/'+dateParts.substring(3,5)+'/'+dateParts.substring(6);
//String newDate = payoutDate.day().format() + '/' + payoutDate.month().format() + '/' + payoutDate.year().format();
             // String newDate=  dateParts.day()+'/'+dateParts.month()+'/'+dateParts.year();   
            //Date.dateParts(date2.yearGmt(),date2.monthGmt(),date2.dayGmt()));
                 //system.debug('newDate'+newDate);
                //Date payout_Date = date.valueOf(newDate);
                 //system.debug('payout_Date'+payout_Date);
                 //
               Date payoutDate = date.parse(pay.payout_Date);
                system.debug('payoutDate'+payoutDate);
                            //opp.CloseDate = closedDate;  
        updatePaymentMap.get('ppgf:'+ pay.transaction_ID).Gateway_Payout_Date__c = date.valueOf(payoutDate);
        updatePayement.add(updatePaymentMap.get('ppgf:'+ pay.transaction_ID));
            }
        }
        system.debug('updatePayement ===>>>'+ updatePayement);
        Database.update(updatePayement, false);
    }
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
        log.Campaign_Created__c = String.valueOf(no_camp);
        log.Contact_created__c = String.valueOf(no_con);
        log.Opportunities_created__c =String.valueOf(no_opp);
        update log;
    }
}