/********************************************************************************************
* @Name         JotFormQuestionUpdateScheduler
* @Author       Navneet Sharma
* @Date         12/7/2023
* @Description  This class is used to Update Question Values on JotForm   
******************************************************************************************* 
MODIFICATION LOG
* Version          Developer          Date               Description
*
*  1.0            Navneet Sharma    12/07/2023         Initial Creation                                                      
******************************************************************************************* */
public with sharing class JotFormQuestionUpdateScheduler implements Schedulable {
    public JotFormQuestionUpdateScheduler() {

    }

    // Wrapper Class for Questions
    public class Questions {
        public String qid;
        public String options;

        public Questions(String qid, String options) {
            this.qid = qid;
            this.options = options;
        }
    }

    public void execute(SchedulableContext SC) {
        // Bulkify the query
        mockMethod();
    }
    
    
    @future(callout=true)
    public static void mockMethod(){
        List<Jotform_Question_Update__mdt> questionsToUpdate = [SELECT ID, Form_ID__c, Question_ID__c,
            Query__c, Object_Name__c, Field_Name__c
            FROM Jotform_Question_Update__mdt];

        // Map to store the questions for each form
        Map<String, List<Questions>> formQuestionsMap = new Map<String, List<Questions>>();
		
        for (Jotform_Question_Update__mdt metadataRec : questionsToUpdate) {
            String dynamicQuery = metadataRec.Query__c;
            List<SObject> queryResults = Database.query(dynamicQuery);
            if (queryResults != null && queryResults.size() > 0) {
                String optionString = '';
                for (SObject sampleRec : queryResults) {
                    Object fieldValue = sampleRec.get(metadataRec.Field_Name__c);
                    if (String.valueOf(fieldValue) != null && String.valueOf(fieldValue) != '') {
                        optionString += String.valueOf(fieldValue) + '|';
                    }
                }

                if (optionString.endsWith('|')) {
                    // Remove the character from the end of the string
                    optionString = optionString.substring(0, optionString.length() - 1);
                }
                // Split the options, sort them, and then concatenate again
    			List<String> optionsList = optionString.split('\\|');
                System.debug(optionsList);
    			optionsList.sort();
    			optionString = String.join(optionsList, '|');
                System.debug(optionsList);

                // Create the question object
                Questions questionRec = new Questions(String.valueOf(metadataRec.Question_ID__c), optionString);

                // Store the question in the map
                if (!formQuestionsMap.containsKey(metadataRec.Form_ID__c)) {
                    formQuestionsMap.put(metadataRec.Form_ID__c, new List<Questions>());
                }
                formQuestionsMap.get(metadataRec.Form_ID__c).add(questionRec);
            }
        }

        // Iterate through the map and make the callouts
        for (String formId : formQuestionsMap.keySet()) {
            Map<String, List<Questions>> questionMap = new Map<String, List<Questions>>();
            questionMap.put('questions', formQuestionsMap.get(formId));

            // Make the callout
            makeJotformCallout(formId, questionMap);
        }
    }

    // Helper method to make the Jotform API callout
    public static void makeJotformCallout(String formId, Map<String, List<Questions>> questionMap) {
        List<JotForm_Log__c> jotFormLogList = new List<JotForm_Log__c>();
        String apiKey = System.Label.JotFormApiKey;
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint('https://api.jotform.com/form/' + formId + '/questions?apiKey=' + apiKey);
        System.debug('https://api.jotform.com/form/' + formId + '/questions?apiKey=' + apiKey);
        req.setBody(JSON.serialize(questionMap, true));

        // Debug body
        System.debug(req.getBody());

        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            // Log or handle the response
            System.debug('STATUS:' + res.getStatus());
            System.debug('STATUS_CODE:' + res.getStatusCode());
            JotForm_Log__c logRec = new JotForm_Log__c();
            logRec.Response_Status_Code__c = String.valueOf(res.getStatusCode());
            logRec.Response_Body__c	=  res.getBody();
            logRec.Request_Body__c = req.getBody();
            jotFormLogList.add(logRec);
        } catch (System.CalloutException e) {
            // Log or handle the exception
            JotForm_Log__c logRec = new JotForm_Log__c();
            //logRec.Response_Status_Code__c = res.getStatusCode();
            logRec.Request_Body__c = req.getBody();
            logRec.Exception__c = e.getMessage();
            logRec.Exception_Stacktrace__c = e.getStackTraceString();
            jotFormLogList.add(logRec);
            System.debug(e);
        }
        if(jotFormLogList.size()>0 && jotFormLogList != NULL){
            Database.insert(jotFormLogList);
        }
    }
}