/********************************************************************************************
* @Name         ActionButtonLogin
* @Author       Amit Yadav
* @Date         10/16/2023
* @Description  This class is login proxy login into the portal i.e. without entering username 
				and OTP
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         04/12/2024         Initial Creation                                                      
******************************************************************************************* */
//This class is login proxy login into the portal i.e. without entering username and OTP
public class ActionButtonLogin {
    
     // Method to retrieve contact record
    @AuraEnabled(cacheable=true)
    public static String contactRecord(String conId){
        return conId;
    }
    
    // Method to find user and their permission set
    @AuraEnabled(cacheable=true)
    public static PermissionSetWrapper findUser(String contactId) {
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>(); // Declare the variable outside the try block
            
        List<Profile> proList = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members'];    
        List<User> us = [SELECT Id, Name, ContactId FROM User WHERE ContactId = :contactId AND ProfileId = :proList[0].Id];
        PermissionSetWrapper perWrap = new PermissionSetWrapper();        
        if (us.size()> 0) {
            permissionSetAssignments = [SELECT PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :us[0].Id];                
            if (!permissionSetAssignments.isEmpty()) { // Check if the list is empty
				//Return the permission set name based on its name.
                if(permissionSetAssignments[0].PermissionSet.Name == 'Volunteer_Portal_Permissions'){
					//Encrypt the user Id 
                    Blob key = EncodingUtil.base64Decode('50pQJwgGsPMUnDF1Qi1oPg==');
                    Blob data = Blob.valueOf(permissionSetAssignments[0].AssigneeId);
                    Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
                    String encryptData =EncodingUtil.base64Encode(encrypted);
					//Assign value to wrapper class variable 
                    perWrap.permissionSetName = permissionSetAssignments[0].PermissionSet.Name;
                    perWrap.adduserIdToUrl = encryptData;
                    return perWrap;                   
                }
                //Return the permission set name based on its name.
                else if(permissionSetAssignments[0].PermissionSet.Name == 'Family_Portal_Permissions'){
					//Encrypt the user Id 
                    Blob key = EncodingUtil.base64Decode('gt7Mw8+jA++LgE8+U4+oCg==');
                    Blob data = Blob.valueOf(permissionSetAssignments[0].AssigneeId);
                    Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
                    String encryptData =EncodingUtil.base64Encode(encrypted);
					//Assign value to wrapper class variable 
                    perWrap.permissionSetName = permissionSetAssignments[0].PermissionSet.Name;
                    perWrap.adduserIdToUrl = encryptData;
                    return perWrap; 
                }                
            }
        }
            return perWrap;            
        }
        
        // Wrapper class to hold permission set details
        public class PermissionSetWrapper{
            @AuraEnabled public String permissionSetName {get;set;}
            @AuraEnabled public String adduserIdToUrl {get;set;}
        }
    }