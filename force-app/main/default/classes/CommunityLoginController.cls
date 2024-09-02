/********************************************************************************************************
* @Name         CommunityLoginController
* @Author       Amit Yadav
* @Date         02/15/2023
* @Description  This class handle the valunteer login controller for protal site, 
handling various methods for user authentication, permission checks, 
password reset, support contact, picklist value retrieval, incident access verification,
fetch and return incident record, incident comment field updating, and home page content 
retrieval.  
********************************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         02/15/2023         Initial Creation                                                      
*********************************************************************************************************/



public without sharing class CommunityLoginController {
        
    @AuraEnabled
    //This method checks if a user's email and phone number exist in the system and return the user information
    public static UserInfoWrapper checkUsersEmailAndPhone(String userMail) {
        UserInfoWrapper usWrap = new UserInfoWrapper();
        try {
            // Query the User object to retrieve user information based on the provided email
            List<Profile> proList = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1 ];
            List<User> users = [SELECT Id, Email, Phone, Username, MobilePhone,ProfileId,ContactId  FROM User WHERE Email = :userMail AND IsActive=true AND ProfileId=: proList[0].Id];
                       
            Boolean portalUser;
            // Check if a user with the provided email exists and has a valid username for the portal
            if (users.size() > 0 && site.isValidUsername(users[0].Username)) {
                List<Contact> con = [SELECT Id, Email, Phone, MobilePhone FROM CONTACT WHERE Id=:users[0].ContactId LIMIT 1];
                List<PermissionSetAssignment> permissionSetAssignments = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :users[0].Id AND PermissionSet.Name = 'Volunteer_Portal_Permissions']; 
                //Checking size of permission set and returning value according to this 
                if(permissionSetAssignments.size() > 0){ 
                    // Check if the user's phone number is blank or not and assign the value to wrapper class variable
                    if (String.isBlank(users[0].MobilePhone	)) {  
                        if(String.isBlank(con[0].MobilePhone)){ 
                            usWrap.userEmail = users[0].Email;
                            usWrap.message = 'Phone number does not exist';                                                       
                            Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
                            Blob data = Blob.valueOf(users[0].Id);
                            Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
                            usWrap.userId = EncodingUtil.base64Encode(encrypted);  
                        }
                        else{
                            usWrap.userPhone = con[0].MobilePhone;
                            usWrap.userEmail = users[0].Email;
                            usWrap.message = 'Phone number and Email exist does not exist';
                            Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
                            Blob data = Blob.valueOf(users[0].Id);
                            Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
                            usWrap.userId = EncodingUtil.base64Encode(encrypted);  
                        }                       
                    }                                       
                    else {
                        usWrap.userPhone = users[0].MobilePhone;
                        usWrap.userEmail = users[0].Email;
                        System.debug('qqwer1234');
                        usWrap.message = 'Phone number and Email exist does not exist';
                        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
                        Blob data = Blob.valueOf(users[0].Id);
                        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
                        usWrap.userId = EncodingUtil.base64Encode(encrypted); 
                    }
                } 
                else{
                    usWrap.message = 'Do not have Volunteer permission';
                }
            }
            else{
                usWrap.message = 'User not found';
            }
        } catch (Exception e) {
            usWrap.message = 'Error: ' + e.getMessage();
            System.debug('---usWrap.message----'+ e.getMessage());
        }        
        return usWrap;
    }
    
    //This method allows a user to login using OTP sent via email or SMS.It generates an OTP, updates the user's contact record with the OTP, and publishes an event for sending OTP via email or SMS
    @AuraEnabled
    public static String loginUserByOtp(String userEmail, String deliveryMethod) {
        // Check if the user exists in the org
        List<User> existingUser = [SELECT Id, Email, Phone, MobilePhone	 FROM User WHERE Email = :userEmail ];
        
        String generatedOTP;
        if (existingUser.size() > 0 ) {            
            // User exists, generate and send OTP
            generatedOTP = generateOTP();            
            List<Contact> conList = [SELECT Id, Email, Otp__c, SMS_OTP__c, Phone, MobilePhone FROM CONTACT WHERE Email=:userEmail LIMIT 1];
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
                        trimMobileNo = existingUser[0].MobilePhone.replaceAll(' ','').substring(1);
                        trimMobileNo = '+61' + trimMobileNo;
                        sendOtpSms(generatedOTP, trimMobileNo);
                    }
                    else{
                        sendOtpSms(generatedOTP, existingUser[0].MobilePhone);                        
                    }                    
                }
                else if(conList[0].MobilePhone != null){
                    if(conList[0].MobilePhone.replaceAll(' ','').length() == 10 && conList[0].MobilePhone.startsWith('04')){
                        trimMobileNo = conList[0].MobilePhone.replaceAll(' ','').substring(1);
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
            update conLiToUpdate; 
            // You can return a success message or a specific identifier to handle the UI behavior
        }
        return generatedOTP;
    }
    
    //This method is making callout to Send OTP wia SMS.
    @future(callout=true)
    public static void sendOtpSms(String smsOtp, String userPhone){   
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
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
        System.debug(res.getBody());
    }
    
    //This method is to generate OTP and we are calling this method in above class
    private static String generateOTP() {
        // Generate a random 6-digit OTP
        Integer otpValue = (Integer)Math.floor(Math.random() * 900000) + 100000;
        return String.valueOf(otpValue);
    }
    
    
    //This method allows a user to contact support and calling method from another class and return message.
    @AuraEnabled
    public static String contactUs(String subject, String details, String reason, String userId){
        String decryptedString = communityLoginController.decryptedData(userId);
        // Create a support case and get a success message
        String successMsg = PortalContactUs.createCase(subject,details,reason, decryptedString);
        return successMsg;
    }
    

    
    
    //This method retrieves picklist values for a specific field and returns them in a list.
    @AuraEnabled(cacheable = true)
    public static List<String> getPickListValuesIntoList() {
        
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Special_Needs__c.Long_Description__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    // Method to check Incident access based on user and volunteer attendance
    @AuraEnabled
    public static String checkIncidentAccess(String recUserId){
        
        String decryptedString = communityLoginController.decryptedData(recUserId);
        String access; 
        // Fetch the current user's contact information     
        List<User> us = [SELECT Id, ContactId FROM User WHERE Id =:decryptedString];
        // Fetch volunteer attendance records for the user
        List<Volunteer_Attendance__c> volAttendList = [SELECT Id, Participation_Role__c, Volunteer__c,Event__c FROM Volunteer_Attendance__c 
                                                       WHERE Attendance__c = 'Accepted' AND Volunteer__c = :us[0].contactId 
                                                       And (Participation_Role__c = 'Doctor' OR Participation_Role__c = 'Registered Nurse' 
                                                            OR Participation_Role__c = 'Endorsed Enrolled Nurse' OR Participation_Role__c = 'Paramedic' OR Participation_Role__c='Staff')];
         Set<Id> eventSet = new Set<Id>();             
        if(volAttendList.size() > 0){
            Boolean isStaff = false;
            for(Volunteer_Attendance__c volAtt : volAttendList){
                if(volAtt.Participation_Role__c == 'Staff'){
                    isStaff = true;
                    eventSet.add(volAtt.Event__c);
                }        
            }
            Map<String,Incident__c> inciMap = new Map<String, Incident__c>();
            List<Incident__c> lisIncc = new List<Incident__c>();
            if(isStaff){
                List<Incident__c> lisInccforstaff = [SELECT Id, Name, Event_Program_Name__r.recordTypeId, Event_Program_Name__r.StartDate,  
                                                     Event_Program_Name__r.EndDate, Event_Program_Name__r.IsActive, Incident_Date_Time__c, Incident_Type__c, 
                                                     RecordType.DeveloperName, Severity__c, Status__c , Reporters_Name__c FROM Incident__c WHERE Status__c = 'New' AND Event_Program_Name__c in:eventSet
                                                     AND (RecordType.DeveloperName != 'Safeguarding_Children') AND 
                                                     (Event_Program_Name__r.recordTypeId =:Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Volunteer').getRecordTypeId() OR 
                                                      Event_Program_Name__r.recordTypeId =:Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Family_Experience').getRecordTypeId() OR 
                                                      Event_Program_Name__r.recordTypeId =:Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Family_Camp').getRecordTypeId() OR 
                                                      Event_Program_Name__r.recordTypeId =:Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Age_Camp').getRecordTypeId() OR 
                                                      Event_Program_Name__r.recordTypeId =:Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Family_Fun_Day').getRecordTypeId()) AND
                                                     Event_Program_Name__r.IsActive = true ORDER BY Incident_Date_Time__c DESC];
                if(lisInccforstaff.size() > 0){
                
                    for(Incident__c inc : lisInccforstaff){
                        inciMap.put(inc.Id, inc);                        
                     }
                }
            }else{                            
            // Fetch incidents basMedication_Errored on specific criteria
             lisIncc = [SELECT Id, Name, Event_Program_Name__r.recordTypeId, Event_Program_Name__r.StartDate,  
                                         Event_Program_Name__r.EndDate, Event_Program_Name__r.IsActive, Incident_Date_Time__c, Incident_Type__c, 
                                         RecordType.DeveloperName, Severity__c, Status__c , Reporters_Name__c FROM Incident__c WHERE Status__c = 'New' 
                                         AND (RecordType.DeveloperName = 'Injury' OR RecordType.DeveloperName = 'Illness' OR RecordType.DeveloperName = 
                                              'Medication_Error' OR RecordType.DeveloperName = 'Behaviour_Incident') AND Event_Program_Name__r.recordTypeId =
                                         :Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Age_Camp').getRecordTypeId() AND
                                         Event_Program_Name__r.IsActive = true ORDER BY Incident_Date_Time__c DESC];
			}
            
            LIST<Incident__c> incidentList = new LIST<Incident__c>();
            // Filter incidents based on date range
            
            if(lisIncc.size() > 0){              
                 for(Incident__c inc : lisIncc){
                        inciMap.put(inc.Id, inc);                         
                     }
            }
            if(inciMap.size() > 0 ){
                for(Incident__c liIn:inciMap.values()){
                    Date start = liIn.Event_Program_Name__r.StartDate ;
                    Date endDate = liIn.Event_Program_Name__r.EndDate.addDays(2);         
                    if(start <= date.valueOf(liIn.Incident_Date_Time__c)){
                        if(date.valueOf(liIn.Incident_Date_Time__c) <= endDate){
                            incidentList.add(liIn);
                        }                  
                    }
                }
            }
            // Serialize the incidentList to JSON
            String serilzeData = JSON.serialize(incidentList);    
            access = serilzeData;
        }
        else{
            access = 'No access';
        }
        return access;
    }
    
    // Method to fetch a specific Incident record and return that record
    @AuraEnabled
    public static Incident__c fatchIncidentRecord (String recordId){
                        
        Incident__c incident =[SELECT Id, Incident_Date_Time__c, RecordType.Name ,Severity__c, Status__c, Stakeholder_s_Involved__c, 
                               Stakeholder_s_Other__c, Incident_Location__c, Incident_description__c, Were_emergency_services_required__c,
                               Was_first_aid_required__c, First_Aid_provided__c, First_Aider__c, Incident_Type__c, Type_of_Behaviour__c, 
                               Observed_Triggers__c, Staff_Volunteers_Involved__c, Injuries_sustained__c,Reporters_Name__c,
                               Nature_of_bodily_injury__c, Emergency_Contact_Notified__c, Call_Details__c, Supervisor_Name__c, 
                               Supervisor_Notified_Date__c, Actions_taken__c, Volunteer_Comments__c FROM Incident__c WHERE Id =:recordId];
        return incident;
    }
    
    // Method to update comments on an Incident record
    @AuraEnabled
    public static String updateCommentIncident(String comment , String recordId){
        Incident__c inci = [SELECT Id, Volunteer_Comments__c FROM Incident__c WHERE Id =:recordId];
        inci.Volunteer_Comments__c = comment;
        update inci;
        return 'Updated Record';
    }
    
    //This method is to retrive the user name to display in the icon 
    @AuraEnabled
    public static User avtarUser(String reocrdId){      
        String decryptedString = communityLoginController.decryptedData(reocrdId);        
        User us = [SELECT Id, UserName, Firstname, Name ,Lastname, Email,Contact.LastName, Contact.Firstname,Contact.Name FROM User WHERE Id=:decryptedString];
        return us;               
    }
    
    // Method to fetch information for the home page content and return it to display on UI 
    @AuraEnabled
    public static Page__c homePageContect(){       
        Page__c pg = [SELECT Id, Name, Site__r.Name, Content__c FROM Page__c WHERE NAME ='Volunteers Home Page' AND Site__r.Name = 'Camp Quality Volunteers'];
        return pg;
    }
    
    public static String decryptedData(String userIdTODecrypt){
        String encryptedString = userIdTODecrypt;
        Blob cipherText = EncodingUtil.base64Decode(encryptedString);
        Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
        Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, cipherText);
        String decryptedString = decrypted.toString();
        return decryptedString; 
    }
    
    
    
    //Wrapper class to display user's information 
    public Class UserInfoWrapper{
        @AuraEnabled public String userPhone {get; set;}
        @AuraEnabled public String userEmail {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public String userId {get; set;}
    }
}