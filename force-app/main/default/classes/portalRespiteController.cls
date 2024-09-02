public class portalRespiteController {

    public List<Property__c> properties {get; set;}
    public Boolean eligible {get;set;}
    public Boolean sEligible {get;set;}
//    public String aId{get;set;}

    public portalRespiteController(){
        properties = new List<Property__c>([
                SELECT
                        Address__c,Available_for_booking_portal__c,
                        Can_extend_to_full_week_an_own_expense__c,
                        Guests__c,Id,Image_URL__c,Length_of_stay__c,
                        Name,Peak_period_restrictions__c,Portal_Description__c,
                        State__c,Type__c
                FROM
                        Property__c
                WHERE
                        Available_for_booking_portal__c = TRUE
            order by type__C
        ]);





        String aId = [Select AccountId from User where id =: Userinfo.getUserid() LIMIT 1].AccountId;

        System.debug(aId);

        for(Account a :[SELECT Id,Name,Eligible_for_Respite_General__c,Eligible_for_Respite_Salamander__c FROM Account WHERE Id =: aId]){
            eligible = a.Eligible_for_Respite_General__c;
            sEligible = a.Eligible_for_Respite_Salamander__c;
        }


//        String cId = [Select ContactId from User where id =: Userinfo.getUserid() LIMIT 1].ContactId;
//
//        for(Contact c :[SELECT Id,Name,eligible_for_Respite_Retreats__c,Respite_Salamander_Eligible__c FROM Contact WHERE Id =: cId]){
//            eligible = c.eligible_for_Respite_Retreats__c;
//            sEligible = c.Respite_Salamander_Eligible__c;
//        }
    }
}