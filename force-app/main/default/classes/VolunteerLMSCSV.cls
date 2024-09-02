public class VolunteerLMSCSV {
	
    @testVisible
    private List<Contact> cons {get;set;}
    
    public String csvString {get;set;}
    
    public VolunteerLMSCSV(ApexPages.StandardSetController controller) {
        if(!Test.isRunningTest())
            controller.addFields(new List<String>{'Constituent_ID__c', 'FirstName', 'LastName', 'Email', 'Branch_Office__c', 'MailingState', 'Volunteer_Types_Training__c'});
        
        controller.setPageSize(999);
        cons = (List<Contact>)controller.getRecords();
        getLMSExport();
    }
    
    public void getLMSExport() {
        
        csvString = 'Username,Password,First Name,Surname,Location,State,Email,Volunteer Type 1,Volunteer Type 2,Volunteer Type 3,Volunteer Type 4,Volunteer Type 5,Volunteer Type 6,Volunteer Type 7,Volunteer Type 8,Volunteer Type 9,Volunteer Type 10,Role\n';
        
        for(Contact con : cons) {
            Set<String> volTypes = new Set<String>();
            
            if(String.isNotBlank(con.Volunteer_Types_Training__c )) { 
            	volTypes.addAll(con.Volunteer_Types_Training__c.split(';'));
            }
            
            String rowString = 	con.Constituent_Id__c + ',WeLoveVolunteers1!,';
            
            rowString += String.isNotBlank(con.FirstName) ? con.FirstName + ',' : ',';
            rowString += String.isNotBlank(con.LastName) ? con.LastName + ',' : ','; 
            rowString += String.isNotBlank(con.Branch_Office__c) ? con.Branch_Office__c + ',' : ',';
            rowString += String.isNotBlank(con.MailingState) ? con.MailingState + ',' : ',';
            rowString += String.isNotBlank(con.Email) ? con.Email + ',' : ',';
            
            rowString += volTypes.contains('Registered Nurse') ? 'Registered Nurse,' : ',';
            rowString += volTypes.contains('Camp Leader') ? 'Camp Leader,' : ',';
            rowString += volTypes.contains('Companion Support') ? 'Companion Support,' : ',';
            rowString += volTypes.contains('Companion/Rover') ? 'Companion/Rover,' : ',';
            rowString += volTypes.contains('Doctor') ? 'Doctor,' : ',';
            rowString += volTypes.contains('Endorsed Enrolled Nurse') ? 'Endorsed Enrolled Nurse,' : ',';
            rowString += volTypes.contains('Events/Fundraising') ? 'Events/Fundraising,' : ',';
            rowString += volTypes.contains('Fundraising Support Group') ? 'Fundraising Support Group,' : ',';
            rowString += volTypes.contains('First Aider') ? 'First Aider,' : ',';
            rowString += volTypes.contains('Office Administration') ? 'Office Administration,' : ',';
            rowString += 'Volunteer\n';
            
            csvString += rowString;
        }
        
    }
    
}