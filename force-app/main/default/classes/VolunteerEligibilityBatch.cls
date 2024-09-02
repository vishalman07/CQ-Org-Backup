/********************************************************************************************
* @Name         VolunteerEligibilityBatch
* @Author       Amit Yadav
* @Date         06/08/2024
* @Description   This Apex class is a batch process that updates the volunteer status based on 
*               compliance criteria and eligibility requirements. The batch processes the 
*               Volunteer_Type__c records, checks their associated Volunteer_Compliance__c 
*               records, and updates the Volunteer_Type__c records' status accordingly.
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         06/08/2024       Initial Creation                                                      
********************************************************************************************/

global class VolunteerEligibilityBatch implements Database.Batchable<SObject>, Database.Stateful {
    String query;
    String contactId;
    public VolunteerEligibilityBatch(String conId){
        this.contactId = conId;
        query = 'SELECT Id, Volunteer_Status__c, Volunteer_Type__c, Volunteer__c, ' +
            'Volunteer__r.Volunteer_Types__c, ' +
            'Volunteer__r.RecordType.DeveloperName, ' +
            'Volunteer__r.Volunteer_Status__c ' +
            'FROM Volunteer_Type__c ' +
            'WHERE Volunteer_Status__c != \'Inactive\' ' +
            'AND Volunteer__r.RecordType.DeveloperName = \'volunteer\' ' +
            'AND Volunteer__c = :contactId ' +
            'AND (Volunteer__r.Volunteer_Status__c = \'Volunteer\' ' +
            'OR Volunteer__r.Volunteer_Status__c = \'OnBoarding\')' ;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('Inside Start Method ==>');
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Volunteer_Type__c> scope) {
        system.debug('Inside Execute Method ==>'+scope);
        // Collect necessary IDs and maps from the scope records
        Set<Id> volunteerTypeIds = new Set<Id>();
        Map<Id,string> volunteerTypeMap= new Map<Id, string>();
        Map<Id, List<Volunteer_Compliance__c>> complianceMap = new Map<Id, List<Volunteer_Compliance__c>>();
        Map<Id, string> volunteerTypesContactMap = new Map<Id, string>();
        for (Volunteer_Type__c vt : scope) {
            if(vt.Volunteer__c != NULL ){
                volunteerTypeIds.add(vt.Volunteer__c); 
                if(!volunteerTypesContactMap.containsKey(vt.Volunteer__c)){
                    volunteerTypesContactMap.put(vt.Volunteer__c, vt.Volunteer_Type__c);
                }
                
            }
        }
        system.debug('volunteerTypeIds---'+volunteerTypeIds);
        system.debug('volunteerTypesContactMap- KEYSET--'+volunteerTypesContactMap.keyset());
        system.debug('volunteerTypesContactMap- VALUES--'+volunteerTypesContactMap.values());
        // Fetch and organize Volunteer_Compliance__c records
        for (Volunteer_Compliance__c compliance : [SELECT Id, Status__c, Volunteer_Name__c, Volunteer_Name__r.RecordType.DeveloperName , Volunteer_Name__r.RecordTypeId FROM Volunteer_Compliance__c WHERE Volunteer_Name__r.RecordType.DeveloperName = 'Volunteer' AND  Volunteer_Name__c IN :volunteerTypeIds AND Volunteer_Name__r.Volunteer_Status__c IN ('Volunteer', 'Onboarding') ]) {
            if (!complianceMap.containsKey(compliance.Volunteer_Name__c)) {
                complianceMap.put(compliance.Volunteer_Name__c, new List<Volunteer_Compliance__c>());
            }
            complianceMap.get(compliance.Volunteer_Name__c).add(compliance);
        }
        system.debug('complianceMap KEYSET ==> '+complianceMap.keySet());
        system.debug('complianceMap VALUES ==> '+complianceMap.values());
        // Fetch Volunteer Eligibility Criteria
        Set<String> criteriaValue = new Set<String>();
        List<Volunteer_Eligibility__c> eligibilityCriteria = [ SELECT Id, Volunteer_Eligibility_Criteria__c, Eligibility_Active__c, Volunteer_Role__c 
                                                              FROM Volunteer_Eligibility__c  WHERE Eligibility_Active__c = true AND Volunteer_Role__c IN: volunteerTypesContactMap.values()];
        System.debug('eligibilityCriteria =LIST=> ' + eligibilityCriteria);
        System.debug('eligibilityCriteria =SIZE=> ' + eligibilityCriteria.size());
        for (Volunteer_Eligibility__c ve : eligibilityCriteria) {
            if (ve.Volunteer_Eligibility_Criteria__c != null) {
                String[] values = ve.Volunteer_Eligibility_Criteria__c.split(';');
                for (String value : values) {
                    criteriaValue.add(value.trim());
                    system.debug('value.trim() ==> '+ value.trim());
                }
            }
        }        
        system.debug('criteriaValue =SIZE=> '+ criteriaValue.size());
        system.debug('criteriaValue =LIST=> '+ criteriaValue);
        Set<Id> volunteerCriteriaId = new Set<Id>();
        // Fetch and filter Volunteer_Criteria__c records
        List<Volunteer_Criteria__c> volunteerCriteriaList = [
            SELECT Id, Volunteer_Criteria__c, Criteria_Status__c, Name FROM Volunteer_Criteria__c where Criteria_Status__c = 'Active'];
        for (Volunteer_Criteria__c vc : volunteerCriteriaList) {
            if (criteriaValue.contains(vc.Name)) {
                system.debug('vc.Name ==> '+ vc.Name );
                volunteerCriteriaId.add(vc.Id); 
            }
        }
        
        Map<Id, String> contactIdvsStatusMap = new Map<Id, String>();
        for (Volunteer_Compliance__c compliance : [SELECT Id, Status__c, Criteria_Type__c  FROM Volunteer_Compliance__c WHERE Volunteer_Name__c = :scope[0].Volunteer__c AND Volunteer_Criteria__c = :volunteerCriteriaId]) {
            
            if (compliance.Status__c == 'Active') {
                contactIdvsStatusMap.put(scope[0].Volunteer__c, 'Active');
                system.debug('line 117-----'+compliance.Status__c);
                system.debug('line 118-----'+contactIdvsStatusMap.values());
            }  if (compliance.Status__c == 'Inactive') {
                contactIdvsStatusMap.put(scope[0].Volunteer__c, 'Pending');
                system.debug('line 121-----'+compliance.Status__c);
                system.debug('line 122-----'+contactIdvsStatusMap.values());
            }
            
            if(compliance.Status__c != 'Active' && compliance.Status__c != 'Inactive'){
                contactIdvsStatusMap.put(scope[0].Volunteer__c, 'Assigned');
                system.debug('line 127-----'+compliance.Status__c);
                system.debug('line 128-----'+contactIdvsStatusMap.values());
            }
        }
        
        // Update Volunteer_Type__c records with the new status
        List<Volunteer_Type__c> updateList = new List<Volunteer_Type__c>();
        for(Volunteer_Type__c vt : scope){
            if(vt.Volunteer__c != NULL  ){
                String status = contactIdvsStatusMap.get(vt.Volunteer__c);
                if (status != null) {
                    vt.Volunteer_Status__c = status;
                    updateList.add(vt);
                    System.debug('--updateList--'+ updateList);
                }
            }
        }
        if(!updateList.isEmpty()){
            system.debug('updateList 146=='+updateList);
            UPDATE updateList;
        }
    }
    public void finish(Database.BatchableContext BC) {
        system.debug('Inside Finish Method ==>');
    } 
}