/********************************************************************************************
* @Name         PortalContactUs
* @Author       Amit Yadav
* @Date         10/09/2023
* @Description  This class handle the valunteer conatctUs for protal site  
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         10/09/2023         Initial Creation                                                      
******************************************************************************************* */

public without sharing class PortalContactUs {
    
    //Retrive all the contacts field and insert the cases and return the success message
    public static String createCase(String subject, String details, String reason, String userId){
        List<User> uList = new List<User>();
        uList = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        String successMsg;
        if(!uList.isEmpty()) {
            
            //Retrive all the contacts fields
            List<Contact> cList = new List<Contact>();
            cList = [SELECT Id, Name, FirstName, LastName, Email, HomePhone, MailingStreet, MailingCity,
                     MailingState, MailingPostalCode, MailingCountry, AccountId
                     FROM Contact WHERE Id = :uList[0].ContactId];
            
            if(!cList.isEmpty()) {
                //Getting the recordtype Id by developer Name and create a case
                //Id rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Respite_Case').getRecordTypeId();
                Id rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Volunteer_Request').getRecordTypeId();
                case cas = new case();
                cas.RecordTypeId = rTypeId;
                cas.Subject = subject;
                cas.AccountId = cList[0].AccountId;
                cas.ContactId = cList[0].Id;
                cas.Status = 'New';
                cas.Origin = 'Community';
                cas.Type = 'Question';
                cas.Reason = reason;
                cas.Description = details;
                //if(!Test.isRunningTest()) {
                for(AssignmentRule ar : [select id from AssignmentRule where SobjectType = 'Case' and Active = true]) {
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= ar.id;
                    cas.setOptions(dmlOpts);
                }
                //}
                
                //Insert case record
                try{
                    insert cas; 
                } catch(DmlException ex) {
                    System.debug(ex);
                    return ex.getMessage();
                }
                successMsg = 'Your message has been received. Someone will contact you shortly.';
            }
        }
        //Returning the success message
        return successMsg;
    }
    
    //Retrive all the contacts field and insert the cases and return the success message
    public static String createCaseforFamily(String subject, String details, String reason, String userId){
        List<User> uList = new List<User>();
        uList = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        String successMsg;
        if(!uList.isEmpty()) {
            
            //Retrive all the contacts fields
            List<Contact> cList = new List<Contact>();
            cList = [SELECT Id, Name, FirstName, LastName, Email, HomePhone, MailingStreet, MailingCity,
                     MailingState, MailingPostalCode, MailingCountry, AccountId
                     FROM Contact WHERE Id = :uList[0].ContactId];
            Id rTypeId;
            if(!cList.isEmpty()) {
                //Getting the recordtype Id by developer Name and create a case
                //Id rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Respite_Case').getRecordTypeId();
                if(reason == 'Enquiry for Respite'){
                     rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Respite_Case').getRecordTypeId();
                }
                else{
                     rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Family_Request').getRecordTypeId();
                }
                case cas = new case();
                cas.RecordTypeId = rTypeId;
                cas.Subject = subject;
                cas.AccountId = cList[0].AccountId;
                cas.ContactId = cList[0].Id;
                cas.Status = 'New';
                cas.Origin = 'Community';
                cas.Type = 'Question';
                cas.Reason = reason;
                cas.Description = details;
                //if(!Test.isRunningTest()) {
                for(AssignmentRule ar : [select id from AssignmentRule where SobjectType = 'Case' and Active = true]) {
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= ar.id;
                    cas.setOptions(dmlOpts);
                }
                //}
                
                //Insert case record
                try{
                    insert cas; 
                } catch(DmlException ex) {
                    System.debug(ex);
                    return ex.getMessage();
                }
                successMsg = 'Your message has been received. Someone will contact you shortly.';
            }
        }
        //Returning the success message
        return successMsg;
    }
    
    
    @auraEnabled
    public static String createLoginCase(String subject, String details, String reason){
        //Getting the recordtype Id by developer Name and create a case
        Id rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Respite_Case').getRecordTypeId();
		//Id rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Volunteer_Request').getRecordTypeId();
        case cas = new case();
        cas.RecordTypeId = rTypeId;
        cas.Subject = subject;
        cas.Status = 'New';
        cas.Origin = 'Community';
        cas.Type = 'Question';
        cas.Reason = reason;
        cas.Description = details;
        //Insert case record
        try{
            insert cas; 
        } catch(DmlException ex) {
            return ex.getMessage();
        }
       return 'Your message has been received. Someone will contact you shortly.';
    }
}