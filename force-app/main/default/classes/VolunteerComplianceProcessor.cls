/*********************************************************************************************************************************************
* @Name         VolunteerComplianceProcessor
* @Author       Amit Yadav
* @Date         21/05/2024
* @Description  The VolunteerComplianceProcessor class is a batch Apex job that processes volunteer compliance records. It queries records
                from the Volunteer_Compliance__c object, makes an HTTP callout to retrieve course completion data from an external API, 
                and updates the records with the latest completion status and details. Additionally, it implements the Schedulable interface 
                to allow scheduling the batch job

********************************************************************************************************************************************** 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         21/05/2024       Initial Creation                                                      
*********************************************************************************************************************************************/


/*The VolunteerComplianceProcessor class is a batch Apex job that processes volunteer compliance records. It queries records
from the Volunteer_Compliance__c object, makes an HTTP callout to retrieve course completion data from an external API, 
and updates the records with the latest completion status and details. Additionally, it implements the Schedulable interface 
to allow scheduling the batch job*/


public class VolunteerComplianceProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute        
        String query = 'SELECT Id, Volunteer_Criteria__r.Name, Status__c, Volunteer_Criteria__r.Display_Order__c, Litmos_Course_ID__c, Criteria_Type__c, Volunteer_Name__c FROM Volunteer_Compliance__c WHERE Litmos_Course_ID__c != null AND CreatedDate > LAST_N_MONTHS:6 AND (Status__c = \'Assigned\' OR Status__c = \'In Progress\') ORDER BY Volunteer_Criteria__r.Display_Order__c ASC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Volunteer_Compliance__c> volList) {
        
        String baseUrl = 'callout:LitmusApiCre/users/8GNedawgiwU1/courses?source=cqportal&format=json&limit=20&start=3';
        HttpRequest req = new HttpRequest();                 
        req.setMethod('GET');
        req.setEndpoint(baseUrl);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        set<String> setOfOrginalId = new set<String>();
        List<RefreshResponse> ref = (List<RefreshResponse>) System.JSON.deserialize(res.getBody(), list<RefreshResponse>.class);
        Map<String,RefreshResponse> refMap = new Map<String,RefreshResponse>();
        
        for(RefreshResponse r:ref){
            refMap.put(r.OriginalId, r);
        }
        

        for(RefreshResponse refRes : ref){
            setOfOrginalId.add(refRes.OriginalId);
        }
        // process each batch of records
        for(Volunteer_Compliance__c volCom : volList){
            if(setOfOrginalId.contains(volCom.Litmos_Course_ID__c) && refMap.get(volCom.Litmos_Course_ID__c).Complete != false ){
                volCom.PercentageComplete__c  = refMap.get(volCom.Litmos_Course_ID__c).PercentageComplete; 
                if(refMap.get(volCom.Litmos_Course_ID__c).PercentageComplete  > 0  && refMap.get(volCom.Litmos_Course_ID__c).PercentageComplete < 100){
                    volCom.Status__c  ='In Progress';
                }
                Boolean istrueComplete = refMap.get(volCom.Litmos_Course_ID__c).Complete;
                if(istrueComplete){
                    volCom.Status__c  ='Active';
                }
                volCom.Litmos_Course_Overdue__C    = refMap.get(volCom.Litmos_Course_ID__c).Overdue;
                
                // Ensure volCom.Litmos_Course_ID__c is not null and refMap contains the corresponding value
                if (volCom.Litmos_Course_ID__c != null && refMap.containsKey(volCom.Litmos_Course_ID__c)) {
                    // Get the DateCompleted value from refMap
                    String dateCompletedValue = refMap.get(volCom.Litmos_Course_ID__c).DateCompleted;
                    
                    // Check if DateCompleted is not null
                    if (dateCompletedValue != null) {
                        // Find the index of '+' in the DateCompleted value
                        Integer plusIndex = dateCompletedValue.indexOf('+');
                        
                        // Check if '+' is found
                        if (plusIndex != -1) {
                            // Extract the substring containing the timestamp
                            String timestampStr = dateCompletedValue.substring(6, plusIndex);
                            
                            // Convert the timestamp string to milliseconds
                            Long timestampMillis = Long.valueOf(timestampStr);
                            
                            // Create DateTime instance from milliseconds
                            DateTime dateTimes = DateTime.newInstance(timestampMillis);
                            
                            // Extract year, month, and day from the DateTime object
                            Integer year = dateTimes.year();
                            Integer month = dateTimes.month();
                            Integer day = dateTimes.day();
                            
                            // Create Date instance from year, month, and day
                            Date dateCompleted = Date.newInstance(year, month, day);
                            
                            // Assign the date to the Date_Completed__c field
                            volCom.Date_Completed__c = dateCompleted;
                            
                        } 
                    }
                } 
            }
        }
        try{
            update volList;
            System.debug('Data updated');
        }
        catch(Exception e){
            System.debug('Error--'+ e.getMessage());
        }        
    }   
    
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    
    
    //Sechdule the batch class
    public void execute(SchedulableContext sc)
    {
        VolunteerComplianceProcessor batchToExe = new VolunteerComplianceProcessor(); // Your batch class
        database.executeBatch(batchToExe , 50);
    }
    
    //Wrapper Class to to store the responce in variables
    public class RefreshResponse {
        public String Id;
        public Boolean Active;
        public Boolean Complete;
        public Double PercentageComplete;
        public String DateCompleted;
        public Boolean Overdue;
        public String OriginalId;
    }
}