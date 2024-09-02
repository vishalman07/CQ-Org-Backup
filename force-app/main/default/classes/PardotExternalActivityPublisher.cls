/********************************************************************************************
* @Name         PardotExternalActivityPublisher
* @Author       Amit Yadav
* @Date         11/17/2023
* @Description  This class is used to publish External Activities to Pardot   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0             Amit Yadav         11/17/2023         Initial Creation                                                      
******************************************************************************************* */
public with sharing class PardotExternalActivityPublisher {
    public static final Integer HTTP_REQUESTS_PER_BATCH = 50;
    public static final String ONLY_ONE_BUSINESS_UNIT_ID = '0Uv1y0000004C9rCAE';
    public static final String NAMED_CREDENTIAL = 'APEX_Pardot_Credential';

    public class ExternalActivity {
        // @InvocableVariable(label='Business Unit Id')
        // public String businessUnitId;
        @InvocableVariable(label='Extension' required=true)
        public String extension;
        @InvocableVariable(label='Type' required=true)
        public String type;
        @InvocableVariable(label='Value' required=true)
        public String value;
        @InvocableVariable(label='Prospect Email' required=true)
        public String email;
    }

    @InvocableMethod(label='Send Activity to Pardot')
    public static void sendActivityToPardot(List<ExternalActivity> activities) {
        //Very quickly pass this request into the ASYNC Queue, eliminating delays for Users
        System.enqueueJob(new QueueablePardotCall(activities));
    }

    /**
     * Handles Asynchronously firing each Activity to Pardot
     */
    public class QueueablePardotCall implements System.Queueable, Database.AllowsCallouts {
        private List<ExternalActivity> activities;

        public QueueablePardotCall(List<ExternalActivity> activities) {
            this.activities = activities;
        }

        public void execute(System.QueueableContext ctx) {
            //depending on how many Activities we are processing, we might hit the APEX limit of 100 Web Callouts
            List<ExternalActivity> remainingActivities = new List<ExternalActivity>();
            Integer processedCount = 0;

            for(ExternalActivity activity : activities) {
                if(processedCount < HTTP_REQUESTS_PER_BATCH ) {
                    HttpRequest req = new HttpRequest();
                    req.setHeader('Pardot-Business-Unit-Id', ONLY_ONE_BUSINESS_UNIT_ID);
                    req.setHeader('Content-Type', 'application/json');
                    // req.setHeader('Pardot-Business-Unit-Id', activity.businessUnitId);
                    // activity.businessUnitId=null;

                    req.setEndpoint('callout:'+NAMED_CREDENTIAL+'/v5/external-activities');
                    req.setMethod('POST');
                    String body = System.JSON.serialize(activity, true);
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
                    remainingActivities.add(activity); //we will process this in the next batch of Payloads
                }
            }
            if(!remainingActivities.isEmpty()) {
                System.enqueueJob(new QueueablePardotCall (remainingActivities));
            }
        }
    }
}