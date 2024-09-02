public class ProcessLeadMappingController {
    
    //public Id leadId{get;set;}
    public Lead lead {get; set;}
    public String msg {get; set;}
    public ProcessLeadMappingController(ApexPages.StandardController sc) {
        if (!Test.isRunningTest())  {
            sc.addFields(new List<String>{'Id', 'Lead_Mapping_Processed__c'});
            sc.addFields(new List<String>{'Id', 'Lead_Conversion_Validation_Errors__c'});
            sc.addFields(new List<String>{'Id', 'Mapping_Definition_Name__c'});
        }
        
        this.lead = (Lead)sc.getRecord();
    }
    
    public void processLeadMapping() {
        if (this.lead.Lead_Mapping_Processed__c)
            this.msg = 'Lead Mapping has already been processed for this record';
        else {
            if (this.lead.Mapping_Definition_Name__c == 'FamilyApplication' && (this.lead.Lead_Conversion_Validation_Errors__c) <> NULL ) {
                this.msg = ('This lead cannot be converted.  The following errors exist ' + this.lead.Lead_Conversion_Validation_Errors__c );
                
            }
            else {
                ProcessLeadMapping.ProcessLead(this.lead.Id);
                this.msg = 'Lead Mapping has been queued';  
            }
        }
        
        
    }
    
}