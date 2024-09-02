/********************************************************************************************
* @Name         CsvUploadController
* @Author       Amit Yadav
* @Date         07/19/2023
* @Description  This class handle the csv data in json format and craete record for Good2give and Paypal For Fund  
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         07/19/2023         Initial Creation                                                      
******************************************************************************************* */
public Without Sharing class CsvUploadController {
    
    /*
    * @Method Name : good2giveCreate
    * Param : Takes one param as a String which is json of good2give csv data
    * Description : This method creates Campaign, Opportunity, Contact, Account And Payment From good2give csv data
    */  
    @AuraEnabled
    public static void good2giveCreate (String jsonStr){
        System.debug(jsonStr);
          
        //Deserialize Json String to Good2giveWrapper class
        List<Good2giveWrapper> g2gList = (List<Good2giveWrapper>)JSON.deserialize(jsonStr, List<Good2giveWrapper>.class);
        if(g2gList == null || g2gList.size() == 0){
            //Throw Exception when Json data is null
            throw new AuraHandledException('CSV File doesn\'t have rows');
        }
        CsvUploadLog__c csvLog = new CsvUploadLog__c();
		csvLog.File_Type__c = 'Good2Give';
        csvLog.Uploaded_By__c = UserInfo.getUserId();
        insert csvLog;
		Good2GiveBatch batch = new Good2GiveBatch(g2gList , csvLog);
       	ID batchprocessid = Database.executeBatch(batch, Integer.valueOf(Label.CsvUploadBatchSize));
		csvLog.Job_Id__c = String.valueOf(batchprocessid);
        update csvLog;
    }
    @AuraEnabled
    Public static List<csvUploadLogWrapper> updateCsvLog(){
        List<CsvUploadLog__c> csvLogList = [Select Id, Job_Id__c, File_Type__c, Uploaded_By__r.Name, CreatedDate From CsvUploadLog__c ORDER BY CreatedDate DESC limit 4];
        List<csvUploadLogWrapper> csvWrapperList = new List<csvUploadLogWrapper>();
        Map<Id, CsvUploadLog__c> jobIdAndCsvUploadMap = new Map<Id, CsvUploadLog__c>();
        List<AsyncApexJob> jobList = new List<AsyncApexJob>();
        if(csvLogList.size() > 0){
            for(CsvUploadLog__c csv : csvLogList){
                jobIdAndCsvUploadMap.put(csv.Job_Id__c,csv);
            }
        }
        if(jobIdAndCsvUploadMap.values() != null){
            jobList = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, ExtendedStatus 
                       FROM AsyncApexJob WHERE ID IN: jobIdAndCsvUploadMap.keySet()];
        }
        if(jobList.size() > 0){
            for(AsyncApexJob job : JobList){
                csvUploadLogWrapper csvLog = new csvUploadLogWrapper();
                csvLog.jobId = job.Id;
                csvLog.createdDate = (jobIdAndCsvUploadMap.get(job.Id).CreatedDate).format('yyyy-MM-dd HH:mm:ss');
                csvLog.fileType = jobIdAndCsvUploadMap.get(job.Id).File_Type__c;
                csvLog.uploadedBy = jobIdAndCsvUploadMap.get(job.Id).Uploaded_By__r.Name;
                csvLog.totalJobs = job.TotalJobItems;
                csvLog.successJobs = job.JobItemsProcessed;
                csvLog.errorJobs = job.NumberOfErrors;
                csvLog.status = job.Status;
                csvLog.extendedStatus = job.ExtendedStatus;
                if(job.JobItemsProcessed != 0 && job.TotalJobItems != 0)
                csvLog.jobPer = Math.round(100 * job.JobItemsProcessed / job.TotalJobItems);
                csvWrapperList.add(csvLog);
            }
        }
        if(csvWrapperList.size() >0){
            return csvWrapperList;
        }
        else {
            return null;
        }
    }
        /*
    * @Wrapper Class : Good2giveWrapper
    * @Description : Use for Deserialize the json of Good2give  
    * 
    */
    public  class csvUploadLogWrapper{
        @AuraEnabled public String jobId {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String fileType {get; set;}
        @AuraEnabled public String uploadedBy {get; set;}
        @AuraEnabled public Integer totalJobs {get; set;}
        @AuraEnabled public Integer successJobs {get; set;}
        @AuraEnabled public Integer errorJobs {get; set;}
        @AuraEnabled public String createdDate{get; set;}
        @AuraEnabled public Integer jobPer{get; set;}
        @AuraEnabled public String extendedStatus{get; set;}
    }
    /*
    * @Method Name : paypalCreate
    * Param : Takes one param as a String which is json of paypalCreate csv data
    * Description : This method creates Campaign, Opportunity, Contact, Account And Payment From paypalCreate csv data
    */ 
    @AuraEnabled
    public static String paypalCreate (String jsonStr){
        //Deserialize String json to PaypalWrapper class
        List<PaypalWrapper> paypalList = (List<PaypalWrapper>)JSON.deserialize(jsonStr, List<PaypalWrapper>.class);
        System.debug('Wrappar List==> '+paypalList);
        if(paypalList == null || paypalList.size() == 0){
            //Throw Exception when Json data is null
            throw new AuraHandledException('CSV File doesn\'t have rows');
        }
        CsvUploadLog__c csvLog = new CsvUploadLog__c();
        csvLog.File_Type__c = 'Paypal Giving Fund';
        csvLog.Uploaded_By__c = UserInfo.getUserId();
        insert csvLog;
        PayPalBatch batch = new PayPalBatch(paypalList, csvLog);
       	Id batchprocessid = Database.executeBatch(batch, Integer.valueOf(Label.CsvUploadBatchSize));
		csvLog.Job_Id__c = String.valueOf(batchprocessid);
        update csvLog;
        return 'successful';
    }

    /*
    * @Wrapper Class : Good2giveWrapper
    * @Description : Use for Deserialize the json of Good2give  
    * 
    */
    public  class Good2giveWrapper{
        @AuraEnabled public string payout_Date {get;set;}
        @AuraEnabled public String donation_Date {get;set;}
        @AuraEnabled public String good2Give_Donor_Id {get;set;}
        @AuraEnabled public String donor_Firstname {get;set;}
        @AuraEnabled public String donor_Lastname {get;set;}
        @AuraEnabled public String donor_Email {get;set;}
        @AuraEnabled public String employer_Name {get;set;}
        @AuraEnabled public String donation_Type {get;set;}
        @AuraEnabled public String charity_Project {get;set;}
        @AuraEnabled public String donor_Reference {get;set;}
        @AuraEnabled public String donation_Confirmation_Number {get;set;}
        @AuraEnabled public String donation_Amount {get;set;}

    }
    
    /*
    * @Wrapper Class : Good2giveWrapper
    * @Description : Use for Deserialize the json of Good2give  
    * 
    */
    public  class PaypalWrapper{
        @AuraEnabled public string payout_Date {get;set;}
        @AuraEnabled public String donation_Date {get;set;}
        @AuraEnabled public String donor_First_Name {get;set;}
        @AuraEnabled public String donor_Last_Name {get;set;}
        @AuraEnabled public String donor_Email {get;set;}
        @AuraEnabled public String program_Name {get;set;}
        @AuraEnabled public String reference_Information {get;set;}
        @AuraEnabled public String currency_Code {get;set;}
        @AuraEnabled public String gross_Amount {get;set;}
        @AuraEnabled public String total_Fees {get;set;}
        @AuraEnabled public String net_Amount {get;set;}
        @AuraEnabled public String transaction_ID {get;set;}
        @AuraEnabled public String gateway_Payout_ID {get;set;}

    }
}