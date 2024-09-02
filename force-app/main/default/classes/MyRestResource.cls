@RestResource(urlMapping='/funraisin/*')
global with sharing class MyRestResource {
    @HttpPost
    global static void doPost() {
        String reqData = RestContext.Request.requestBody.toString();
        System.debug('====>Data ===>'+reqData);
        List<Sobject> sobj = (List<SObject>) JSON.deserialize(reqData, List<SObject>.class);
        List<Contact> conList = new List<Contact>();
        for(Sobject obj : sobj){
            if(String.valueOf(obj.getSObjectType()) == 'Contact'){
                Contact con = (Contact) obj;
                conList.add(con);
            }
        }
        if(conList.size() > 0 ){
            insert conList;
        }
        List<Campaign> campList = new List<Campaign>();
        for(Sobject obj : sobj){
            if(String.valueOf(obj.getSObjectType()) == 'Campaign'){
                Campaign camp = (Campaign) obj;
                if(conList.size() > 0){
                    camp.Contact_Fundraising__c = conList[0].Id;
                    camp.Account_Fundraiser__c = conList[0].AccountId;
                }
                campList.add(camp);
            }
        }
        if(campList.size() > 0 ){
            insert campList;
        }
        List<Opportunity> oppList = new List<Opportunity>();
        for(Sobject obj : sobj){
            if(String.valueOf(obj.getSObjectType()) == 'Opportunity'){
                Opportunity opp = (Opportunity) obj;
                if(conList.size() > 0){
                    opp.ContactId = conList[0].Id;
                    opp.AccountId = conList[0].AccountId;
                }
                if(campList.size() > 0){
                    opp.CampaignId = campList[0].Id;
                }
                oppList.add(opp);
            }
        }
        if(oppList.size() > 0 ){
            insert oppList;
        }
    }
}