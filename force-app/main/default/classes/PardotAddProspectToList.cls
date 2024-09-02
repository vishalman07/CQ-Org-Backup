/********************************************************************************************
* @Name         PardotAddProspectToList
* @Author       Amit Yadav
* @Date         11/17/2023
* @Description  This class is used to Add Prospect to Segmented List   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         12/04/2023         Initial Creation                                                      
******************************************************************************************* */
public with sharing class PardotAddProspectToList {
    public static final Integer HTTP_REQUESTS_PER_BATCH = 50;
    public static final String ONLY_ONE_BUSINESS_UNIT_ID = label.Business_Unit_ID;
    public static final String NAMED_CREDENTIAL = label.Named_Credentials;

    public class Prospect {
        @InvocableVariable(label='List Id' required=true)
        public Integer listId;
        @InvocableVariable(label='Prospect Id' required=true)
        public Integer prospectId;
        @InvocableVariable(label='Opted Out' required=true)
        public Boolean optedOut;
    }
    
    @InvocableMethod(label='Add Prospect to List Queueable')
    public static void addProspectToList(List<Prospect> prospects) {
        //Very quickly pass this request into the ASYNC Queue, eliminating delays for Users
        System.enqueueJob(new QueueableProspectAddToList(prospects));
    }


    /**
     * Handles Asynchronously firing each Activity to Pardot
     */
    public class QueueableProspectAddToList implements System.Queueable, Database.AllowsCallouts {
        private List<Prospect> prospects;

        public QueueableProspectAddToList(List<Prospect> prospects) {
            this.prospects = prospects;
        }

        public void execute(System.QueueableContext ctx) {
            //depending on how many Activities we are processing, we might hit the APEX limit of 100 Web Callouts
            List<Prospect> remainingProspects = new List<Prospect>();
            Integer processedCount = 0;

            for(Prospect prospect : prospects) {
                if(processedCount < HTTP_REQUESTS_PER_BATCH ) {
                    HttpRequest req = new HttpRequest();
                    req.setHeader('Pardot-Business-Unit-Id', ONLY_ONE_BUSINESS_UNIT_ID);
                    req.setHeader('Content-Type', 'application/json');
                    // req.setHeader('Pardot-Business-Unit-Id', activity.businessUnitId);
                    // activity.businessUnitId=null;

                    req.setEndpoint('callout:'+NAMED_CREDENTIAL+'/v5/objects/list-memberships?fields=id,optedOut,createdAt,updatedAt,createdById,updatedById,list.name,list.id,prospect.id,prospect.firstName,prospect.lastName,prospect.email');
                    req.setMethod('POST');
                    String body = System.JSON.serialize(prospect, true);
                    System.debug('Submitting: ' + body);
                    req.setBody(body);
                    Http http = new Http();
                    
                    try {
                      httpResponse res = http.send(req);  
                        System.debug(res.getBody());
                        
                    }
                    catch(Exception e) {
                        //we fire it off and don't do anything if there's an error
                        //probably not the best approach for Production, though it will
                        //be up to you how to handle it
                        System.debug('There was an error submitting the External activity');
                        System.debug('Message: ' + e.getMessage() + '\n' +
                                        'Cause: ' + e.getCause() + '\n' +
                                        'Stack trace: ' + e.getStackTraceString());
                    }
                    processedCount++;
                }
                else {
                    remainingProspects.add(prospect); //we will process this in the next batch of Payloads
                }
            }
            if(!remainingProspects.isEmpty()) {
                System.enqueueJob(new QueueableProspectAddToList(remainingProspects));
            }
        }
    }
}