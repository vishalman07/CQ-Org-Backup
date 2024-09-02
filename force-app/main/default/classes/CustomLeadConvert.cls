/********************************************************************************************
* @Name         CustomLeadConvert
* @Author       Amit Yadav
* @Date         29/09/2023
* @Description  This class call CustomLeadConvertBatch batch class for converting the lead.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         29/09/2023         Initial Creation                                                      
******************************************************************************************* */
public class CustomLeadConvert {
    // Method to retrieve leadId from wire adaptar
    @AuraEnabled(cacheable=true)
    public static String leadRecord(String leadId){
        return leadId;
    }
    // Method to convert a lead
    @AuraEnabled
    public static void leadConvert(String leadId){
        
        // Create a LeadConvert object and configure conversion options
        List<Lead> leadList = [Select Id,Email,Parent_1_First_Name__c,Parent_1_Last_Name__c, Parent_1_Email__c, Parent_2_Email__c,RecordType.Name From Lead Where Id =:leadId AND (RecordType.Name = 'Family Application' OR RecordType.Name = 'Family Referral' OR RecordType.Name = 'Volunteer') limit 1];
       if(leadList.size() > 0 && (String.isnotBlank(leadList[0].Parent_1_Email__c) || String.isnotBlank(leadList[0].Email))){
             List<Contact> conList = new List<Contact>();
            if(String.isnotBlank(leadList[0].Email) && LeadList[0].RecordType.Name == 'Volunteer'){
              conList = [Select Id, Email, Name From Contact Where Email =:leadList[0].Email];

            }
            else if(String.isnotBlank(leadList[0].Parent_1_Email__c) && (leadList[0].RecordType.Name == 'Family Application' || leadList[0].RecordType.Name == 'Family Referral')){
             conList = [Select Id, Email, Name From Contact Where Email =:leadList[0].Parent_1_Email__c];
            }
			CustomLeadConvertBatch batchJob = new CustomLeadConvertBatch(leadList);
                Id batchJobId = Database.executeBatch(batchJob, 1);
       }
    }
}