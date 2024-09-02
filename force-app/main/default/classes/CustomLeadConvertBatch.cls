/********************************************************************************************
* @Name         CustomLeadConvertBatch
* @Author       Amit Yadav
* @Date         11/01/2024
* @Description  This batch class convert the lead and run "Lead convert process new" autolaunched flow after geeting result created permissionSetAssignment for contactOwner.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         11/01/2024         Initial Creation                                                      
******************************************************************************************* */
public class CustomLeadConvertBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public List<Lead> leads;
    public String contactId;
    public CustomLeadConvertBatch(List<Lead> leads){
        this.leads = leads;
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Parent_1_First_Name__c, Parent_1_Last_Name__c, Parent_1_Email__c, Parent_2_Email__c From Lead Where Id IN :leads'; // Replace with your own SOQL query
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        LeadConvert__e event = new LeadConvert__e();
        try{
            if(scope.size() == 1){
                Database.LeadConvert convert = new Database.LeadConvert();
                convert.setDoNotCreateOpportunity(true); // Do not create an opportunity during conversion
                convert.setLeadId(scope[0].Id); // Set the leadId to convert
                convert.setConvertedStatus('Successful'); // Set the conversion status
                // Perform the lead conversion
                Database.LeadConvertResult lcResult = Database.convertLead(convert);
                // Check if the lead conversion was successful and get the Contact ID
                if (lcResult.isSuccess()) {
                    String conId = lcResult.getContactId();
                    String accountId = lcResult.getAccountId();
                    this.contactId = conId;
                } else {
                    Database.Error[] dbErrors = lcResult.getErrors();
                    for (Database.error er: dbErrors){
                        event.Message__c = er.getMessage();
                        event.ConvertContactId__c = leads[0].Id;
                    }
                    EventBus.publish(event);
                }
            }
            
            else {
                List<Database.LeadConvert> converts = new List<Database.LeadConvert>();
                for(Lead record: scope) { 
                    Database.LeadConvert convert = new Database.LeadConvert();
                    convert.setLeadId(record.Id); 
                    convert.setConvertedStatus('Successful');
                    converts.add(convert);
                }
                List<Database.LeadConvertResult> lcResult = Database.convertLead(converts, false);          
            }
        }
        catch (exception ex){
            if(scope.size() == 1){
                event.Message__c = ex.getMessage();
                event.ConvertContactId__c = leads[0].Id;
                EventBus.publish(event);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        LeadConvert__e event = new LeadConvert__e();
        // Execute any post-processing logic here
        if(!String.isBlank(contactId)){
            Map<String, Object> flowInputVariables = new Map<String, Object>();          
            // Add the Contact ID and leadId to the input variables map for the flow
            flowInputVariables.put('ContactId', contactId);
            flowInputVariables.put('leadId', leads[0].Id);
            // Create a flow interview
            Flow.Interview.Lead_convert_process_new myFlow = new Flow.Interview.Lead_convert_process_new(flowInputVariables);
            // Start the flow
            myFlow.start();
            Contact con = (Contact) myFlow.getvariableValue('ContactRecord');
            Map<String, Object> emailFlowInputVariables = new Map<String, Object>();          
            emailFlowInputVariables.put('contactRec',con);
            emailFlowInputVariables.put('recordType',con.RecordType.developerName);           
            event.Message__c = 'Lead conversion was successful';
            event.ConvertContactId__c = con.Id;
            EventBus.publish(event);
        }
    }
}