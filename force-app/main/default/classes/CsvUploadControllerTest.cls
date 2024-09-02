/********************************************************************************************
* @Name         CsvUploadControllerTest
* @Author       Amit Yadav
* @Date         07/21/2023
* @Description  This test class cover the CsvUploadController class   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         07/21/2023         Initial Creation                                                      
******************************************************************************************* */
@IsTest
public class CsvUploadControllerTest {
    @testSetup static void createRecord(){
        
        //create parent campaign for good2give
        Campaign parentcamp = new Campaign();
        parentcamp.Name = 'Good2Give';
        parentcamp.Funraisin_Id__c = 'g2g:good2give';
        parentcamp.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        insert parentcamp;
        //create parent campaign for Paypal for Fund
        Campaign parentcamp1 = new Campaign();
        parentcamp1.Name = 'Facebook donations with PPGF';
        parentcamp1.Funraisin_Id__c = 'ppgf:facebook';
        parentcamp1.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        insert parentcamp1;
        //create parent campaign for Paypal for Fund
        Campaign parentcamp2 = new Campaign();
        parentcamp2.Name = 'PayPal Giving Fund - GoFundMe';
        parentcamp2.Funraisin_Id__c = 'ppgf:gofundme';
        parentcamp2.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        insert parentcamp2;
        //create parent campaign for Paypal for Fund
        Campaign parentcamp3 = new Campaign();
        parentcamp3.Name = 'PayPal Giving Fund - PayPal Give at Checkout';
        parentcamp3.Funraisin_Id__c = 'ppgf:pp-give';
        parentcamp3.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        insert parentcamp3;
        //create parent campaign for Paypal for Fund
        Campaign parentcamp4 = new Campaign();
        parentcamp4.Name = 'PayPal Giving Fund - PayPal App and Web Donations';
        parentcamp4.Funraisin_Id__c = 'ppgf:paypal-app-and-web-donations';
        parentcamp4.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        insert parentcamp4;
        //create parent campaign for Paypal for Fund
        Campaign parentcamp5 = new Campaign();
        parentcamp5.Name = 'PayPal Giving Fund - Parent';
        parentcamp5.Funraisin_Id__c = 'ppgf:parent';
        parentcamp5.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        insert parentcamp5;
        Campaign camp = new Campaign();
        camp.Name = 'Testing version rec Pty Limited';
        camp.Funraisin_Id__c = 'g2g:Testing version rec Pty Limited';
        camp.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        insert camp;
        
        Campaign camp1 = new Campaign();
        camp1.Name = 'Testing version 01';
        camp1.Funraisin_Id__c = 'ppgf:000257765565280';
        camp1.RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Fundraising').getRecordTypeId();
        insert camp1;
        
        Account ac = new Account();
        ac.name = 'new testing';
        ac.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organisation').getRecordTypeId();
        ac.Email__c = 'test01@gmail.com';
        insert ac;
        
        Contact con = new Contact();
        con.AccountId = ac.Id;
        con.email = 'test01@gmail.com';
        con.LastName = 'version 01';
        con.FirstName = 'Test01';
        con.RecordTypeId =  Schema.sObjectType.Contact.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
        Insert con;       
    }
    
    @isTest
    static void callingMethod() {
        Test.startTest();       
        String jsonString = '[{"donation_Date":"21-08-2023","good2Give_Donor_Id":"4456","donor_Firstname":"","donor_Lastname":"","donor_Email":"","employer_Name":"Testing version rec Pty Limited","donation_Type":"Employer Matched","charity_Project":"General","donor_Reference":"","donation_Confirmation_Number":"G2GDON0006923851AU","donation_Amount":"$10.00"},{"donation_Date":"21-08-2023","good2Give_Donor_Id":"4456","donor_Firstname":"Testingrec","donor_Lastname":"version 01 rec","donor_Email":"Testtversionrec@gmail.com","employer_Name":"Testing version rec Pty Limited","donation_Type":"Employer Matched","charity_Project":"General","donor_Reference":"","donation_Confirmation_Number":"G2GDON0006923851AU","donation_Amount":"$10.00"},{"donation_Date":"21-08-2023","good2Give_Donor_Id":"4456","donor_Firstname":"Testlogic","donor_Lastname":"version 01 hai","donor_Email":"Testtversionhai@gmail.com","employer_Name":"Testing version 01 Pty Limited","donation_Type":"Employer Matched","charity_Project":"General","donor_Reference":"","donation_Confirmation_Number":"G2GDON0006923851KU","donation_Amount":"$100.00"}]';
        String paypalJson = '[{"payout_Date":"21-07/2023","donation_Date":"15/05/2023","donor_First_Name":"Test01","donor_Last_Name":"version 01","donor_Email":"test01@gmail.com","program_Name":"Facebook donations with PPGF","reference_Information":"000257765576280:Testing version 11","currency_Code":"AUD","gross_Amount":"50","total_Fees":"0","net_Amount":"50","transaction_ID":"7TX43400P55320667"},{"payout_Date":"21/07/2023","donation_Date":"15/05/2023","donor_First_Name":"Anonymous","donor_Last_Name":"","donor_Email":"","program_Name":"Facebook donations with PPGF","reference_Information":"000257765565280:Testing version 01","currency_Code":"AUD","gross_Amount":"50","total_Fees":"0","net_Amount":"50","transaction_ID":"7TX43400P55320927"},{"payout_Date":"21/07/2023","donation_Date":"15/05/2023","donor_First_Name":"Test","donor_Last_Name":"Test","donor_Email":"test@gmail.com","program_Name":"Facebook donations with PPGF","reference_Information":"000917757712921:Testing","currency_Code":"AUD","gross_Amount":"40","total_Fees":"0","net_Amount":"40","transaction_ID":"40124341RB792254K"},{"payout_Date":"21/07/2023","donation_Date":"15/05/2023","donor_First_Name":"Anonymous","donor_Last_Name":"","donor_Email":"","program_Name":"PayPal Giving Fund / GoFundMe","reference_Information":"Testing version 02","currency_Code":"AUD","gross_Amount":"33","total_Fees":"0","net_Amount":"33","transaction_ID":"7TX43400P55328888"},{"payout_Date":"21/07/2023","donation_Date":"15/05/2023","donor_First_Name":"Anonymous","donor_Last_Name":"","donor_Email":"","program_Name":"PayPal Give at Checkout","reference_Information":"","currency_Code":"AUD","gross_Amount":"22","total_Fees":"0","net_Amount":"22","transaction_ID":"7TX43400P55326666"},{"payout_Date":"21/07/2023","donation_Date":"15/05/2023","donor_First_Name":"Anonymous","donor_Last_Name":"","donor_Email":"","program_Name":"PayPal Giving Fund / PayPal App and Web Donations","reference_Information":"","currency_Code":"AUD","gross_Amount":"11","total_Fees":"0","net_Amount":"11","transaction_ID":"7TX43400P55325555"},{"payout_Date":"21/07/2023","donation_Date":"15/05/2023","donor_First_Name":"Anonymous","donor_Last_Name":"","donor_Email":"","program_Name":"87868586576:instagram Donations","reference_Information":"000257765564330:Testing version camp","currency_Code":"AUD","gross_Amount":"50","total_Fees":"0","net_Amount":"50","transaction_ID":"7TX43400P55320877"},{"payout_Date":"21/07/2023","donation_Date":"15/05/2023","donor_First_Name":"Anonymous","donor_Last_Name":"","donor_Email":"","program_Name":"Testing","reference_Information":"","currency_Code":"AUD","gross_Amount":"50","total_Fees":"0","net_Amount":"50","transaction_ID":"7TX43401P95320877"}]';
        try {
            // code that might throw FIELD_CUSTOM_VALIDATION_EXCEPTION
            CsvUploadController.good2giveCreate(jsonString);
            CsvUploadController.updateCsvLog();
            String returnValuePaypal = CsvUploadController.paypalCreate(paypalJson);
            System.assertEquals('successful', returnValuePaypal);
        } catch (Exception e) {
            // Handle other exceptions if needed
            System.debug('Caught an exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}