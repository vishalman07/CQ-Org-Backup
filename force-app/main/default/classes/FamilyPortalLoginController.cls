/********************************************************************************************
* @Name         FamilyPortalLoginController
* @Author       Amit Yadav
* @Date         02/15/2023
* @Description  This apex class is to handle passwordless login ie. by using OTP login in the family portal
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         02/15/2023        Initial Creation                                                      
******************************************************************************************* */ 

//This apex class is to handle passwordless login ie. by using OTP login in the family portal
public without sharing class FamilyPortalLoginController {
    
    //This method checks if a user's email and phone number exist in the system and return the user information
        @AuraEnabled
    public static UserInfoWrapper checkUsersEmailAndPhone(String userMail) {
        UserInfoWrapper usWrap = new UserInfoWrapper();
        try {
             // Query the User object to retrieve user information based on the provided email
            List<Profile> proList = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' ];
            List<User> users = [SELECT Id, Email, Phone, Username, MobilePhone,ContactId FROM User WHERE Email = :userMail AND IsActive=true AND ProfileId=: proList[0].Id];
            Boolean portalUser;
            // Check if a user with the provided email exists and has a valid username for the portal
            if (users.size() > 0 && site.isValidUsername(users[0].Username)) { 
                 List<Contact> con = [SELECT Id, Email, Phone, MobilePhone FROM CONTACT WHERE Id=:users[0].ContactId LIMIT 1];
                // Query PermissionSetAssignment to check if the user has the required permission set
                List<PermissionSetAssignment> permissionSetAssignments = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :users[0].Id AND PermissionSet.Name = 'Family_Portal_Permissions']; 
                //Checking size of permission set and returning value according to this 
                if(permissionSetAssignments.size() > 0){ 
                    // Check if the user's phone number is blank or not
                    if (String.isBlank(users[0].MobilePhone	)) {  
						if(String.isBlank(con[0].MobilePhone)){             
                            usWrap.userEmail = users[0].Email;
                            usWrap.message = 'Phone number does not exist';
                            Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
                            Blob data = Blob.valueOf(users[0].Id);
                            Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);                         
                        	usWrap.userId = EncodingUtil.base64Encode(encrypted);
                            //usWrap.userId = users[0].Id;     
                        }   
                        else{
                            usWrap.userPhone = con[0].MobilePhone;
                            usWrap.userEmail = users[0].Email;
                            usWrap.message = 'Phone number and Email exist does not exist';
                            //Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
                            Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
                            Blob data = Blob.valueOf(users[0].Id);
                            Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);                         
                        	usWrap.userId = EncodingUtil.base64Encode(encrypted);
                            //usWrap.userId = users[0].Id;
                        }
                    }                  
                    else {
                        usWrap.userPhone = users[0].MobilePhone	;
                        usWrap.userEmail = users[0].Email;
                        usWrap.message = 'Phone number and Email exist does not exist';
                        Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
                        Blob data = Blob.valueOf(users[0].Id);
                        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);                         
                        usWrap.userId = EncodingUtil.base64Encode(encrypted);
                        //usWrap.userId = users[0].Id;                    
                    }
                } 
                else{
                    usWrap.message = 'Do not have family permission';
                }
            }
            else{
                usWrap.message = 'User not found';
            }
        } catch (Exception e) {
            usWrap.message = 'Error: ' + e.getMessage();
        }        
        return usWrap;
    }
    
    
    
    //This method allows a user to login using OTP sent via email or SMS.It generates an OTP, updates the user's contact record with the OTP, and publishes an event for sending OTP via email or SMS
    @AuraEnabled
    public static String loginUserByOtp(String userEmail, String deliveryMethod) {
        // Check if the user exists in the org
        List<User> existingUser = [SELECT Id, Email, Phone, MobilePhone	 FROM User WHERE Email = :userEmail ];
        
        String generatedOTP;
        if (existingUser.size()> 0) {            
            // User exists, generate and send OTP
            generatedOTP = generateOTP();
            List<Contact> conList = [SELECT Id, Email, Otp__c, SMS_OTP__c, Phone,MobilePhone FROM CONTACT WHERE Email=:userEmail LIMIT 1];
            System.debug('conList-----------' + conList);
            List<Contact> conLiToUpdate = new List<Contact>();
            //Checking if the user phone number exist or not according to that we are assigning value updating the field in contact Object
            for(Contact con : conList){
                if(!String.isBlank(existingUser[0].MobilePhone)){
                    con.Otp__c = generatedOTP;
                    conLiToUpdate.add(con);
                } else if(!String.isBlank(existingUser[0].Email)){
                    con.SMS_OTP__c = generatedOTP;
                    conLiToUpdate.add(con);
                }  
            }
            update conLiToUpdate; 
            String trimMobileNo;
            //Here we are invoking the and publishing the platform event.
            List<Invoke_Email_and_Send__e> inkEvents = new List<Invoke_Email_and_Send__e>();
            Invoke_Email_and_Send__e myEvent = new Invoke_Email_and_Send__e();
            
            if (deliveryMethod == 'email') {
                myEvent.Email_send_OTP__c = generatedOTP;
                myEvent.getRecordId__c = existingUser[0].Id;
            } 
			 if (deliveryMethod == 'sms') {
				if(existingUser[0].MobilePhone != null ){
                    if(existingUser[0].MobilePhone.replaceAll(' ','').length() == 10 && existingUser[0].MobilePhone.startsWith('04')){
						trimMobileNo = existingUser[0].MobilePhone.replaceAll(' ', '').substring(1);
                        trimMobileNo = '+61' + trimMobileNo;
                        sendOtpSms(generatedOTP, trimMobileNo);
                    }
                    else{
                    	 sendOtpSms(generatedOTP, existingUser[0].MobilePhone);                        
                    }   
                }    
				else if(conList[0].MobilePhone != null){
                    if(conList[0].MobilePhone.replaceAll(' ','').length() == 10 && conList[0].MobilePhone.startsWith('04')){
                        trimMobileNo = conList[0].MobilePhone.replaceAll(' ', '').substring(1);
                        trimMobileNo = '+61' + trimMobileNo;
                        sendOtpSms(generatedOTP, trimMobileNo);
                    } 
                    else{
                        sendOtpSms(generatedOTP, conList[0].MobilePhone);
                    }
                }
            }
            inkEvents.add(myEvent);            
            List<Database.SaveResult> results = EventBus.publish(inkEvents);           
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }       
            }
        }
        return generatedOTP;
    }
    
    
    //This method is making callout to Send OTP wia SMS.
    @future(callout=true)
    public static void sendOtpSms(String smsOtp, String userPhone){   
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (Post) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.messagemedia.com/v1/messages');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization', 'Basic RXRxNDdGZjROTk1JUlBOWUlHdDU6TTNoVThNMGFBUUtNUlZxbGlySjA3b2RSREVpa0I2');
        String body = '{"messages": [{"content": "Enter this code on the Camp Quality Portal: '+smsOtp+'","destination_number":"'+userPhone+'","format": "SMS"}]}';
        req.setBody(body);
        // Send the request, and return a response
        HttpResponse res = h.send(req);
    }
    
    //This method is to generate OTP and we are calling this method in above class
    private static String generateOTP() {
        // Generate a random 6-digit OTP
        Integer otpValue = (Integer)Math.floor(Math.random() * 900000) + 100000;
        return String.valueOf(otpValue);
    }
    
    //This method is to retrive the user name to display in the icon 
    @AuraEnabled
    public static User avtarUser(String reocrdId){      
        String decryptedString = FamilyPortalLoginController.decryptedData(reocrdId);
        User us = [SELECT Id, UserName,Contact.LastName ,  Contact.Firstname, Name ,Lastname, Contact.Name, Email,ContactId FROM User WHERE Id=:decryptedString];
        return us;               
    }
    
    
    
    @AuraEnabled
    public static String contactUs(String subject, String details, String reason, String userId){
        String decryptedString = FamilyPortalLoginController.decryptedData(userId);
        // Create a support case and get a success message
        //String successMsg = PortalContactUs.createCase(subject,details,reason, decryptedString);
        String successMsg = PortalContactUs.createCaseforFamily(subject,details,reason, decryptedString);
        return successMsg;
    }
    
     public static String decryptedData(String userIdTODecrypt){
        String encryptedString = userIdTODecrypt;
        Blob cipherText = EncodingUtil.base64Decode(encryptedString);
        Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
        Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, cipherText);
        String decryptedString = decrypted.toString();
        return decryptedString; 
    }
    
     /*   @AuraEnabled 
    public static String loginContactUsPage(String email, String subject, String details, String reason){
        List<Profile> proList = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1 ];
        //List<User> users = [SELECT Id, Email, Phone,ContactId, Username, MobilePhone,ProfileId  FROM User WHERE Email = :email AND IsActive=true AND Profile.Name = 'My Camp Quality Members']; 
            //Retrive all the contacts fields
            String successMsg;
            List<Contact> cList = new List<Contact>();
            cList = [SELECT Id, Name, FirstName, LastName, Email, HomePhone, MailingStreet, MailingCity,
                     MailingState, MailingPostalCode, MailingCountry, AccountId
                     FROM Contact WHERE  Email =:email ];
			
        	 List<User> users = [SELECT Id, Email, Phone, ContactId, Username, MobilePhone,ProfileId  FROM User WHERE ContactId = :cList[0].Id AND IsActive=true AND Profile.Id =:proList[0].Id]; 
			System.debug('users-------'+ users);
            
            if(!users.isEmpty()) {
                //Getting the recordtype Id by developer Name and create a case
                Id rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Respite_Case').getRecordTypeId();
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
                try{
                    insert cas; 
                } catch(DmlException ex) {
                    System.debug(ex);
                    return ex.getMessage();
                }
                successMsg = 'Your message has been received. Someone will contact you shortly.';
            }
         //Returning the success message
        return successMsg;
    }*/
    
    //Wrapper class to display user's information 
    public Class UserInfoWrapper{
        @AuraEnabled public String userPhone {get; set;}
        @AuraEnabled public String userEmail {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public String userId {get; set;}
       // @AuraEnabled public Boolean portaluserExist {get; set;}
    }
}