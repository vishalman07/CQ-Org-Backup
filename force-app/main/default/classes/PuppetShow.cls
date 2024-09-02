public class PuppetShow {
      
    public static void AddVenue(List<PuppetShow__c> puppetShows) {

        Set<Id> childIds = new Set<Id>();
        Set<PuppetShow__c> psSet = new Set<PuppetShow__c>();

        for(PuppetShow__c ps : puppetShows) {
            if (String.isEmpty(ps.Venue__c) && String.isNotEmpty(ps.Child_Requesting_Show__c)) {
                childIds.add(ps.Child_Requesting_Show__c);
                psSet.add(ps);
            }
        }

        Map<Id, Contact> children = new Map<Id, Contact>([SELECT Id, School__c, School__r.BillingState FROM Contact where Id IN :childIds]);

        for(PuppetShow__c ps : psSet) {

            Contact child = children.get(ps.Child_Requesting_Show__c);

            if(child <> null && String.isNotEmpty(child.School__c) && String.isNotEmpty(child.School__r.BillingState)) {

                Account Venue = child.School__r;
                ps.Venue__c  = Venue.Id;

                if (Venue.BillingState == 'VIC' || Venue.BillingState == 'TAS'  )
                    ps.Performance_group__C = 'VIC/TAS';
                if (Venue.BillingState == 'SA' || Venue.BillingState == 'NT'  )
                    ps.Performance_group__C = 'SA/NT';
                if (Venue.BillingState == 'NSW' || Venue.BillingState == 'ACT'  )
                    ps.Performance_group__C = 'NSW/ACT';
                if (Venue.BillingState == 'QLD' )
                    ps.Performance_group__C = 'QLD';
                if (Venue.BillingState == 'WA' )
                    ps.Performance_group__C = 'WA';

            }

        }
        
    }

    public static void AddKids(List<PuppetShow__c> psList) {

        List<Id> acctIds = new List<Id>();
        List<PSP_Show_Attendee__c> pspattendees = new List<PSP_Show_Attendee__c>();

        for(PuppetShow__c ps : psList) {
            if(String.isNotEmpty(ps.Venue__c)) {
                acctIds.add(ps.Venue__c);
            }
        }

        Map<Id, Account> venueMap = new Map<Id, Account>([SELECT Id, (SELECT Id, Name FROM Students__r WHERE age__C < 14) FROM Account WHERE Id IN :acctIds]);

        for(PuppetShow__c ps : psList) {

            if(String.isNotEmpty(ps.Venue__c) && venueMap.containsKey(ps.Venue__c)) {
                for(Contact c : venueMap.get(ps.Venue__c).Students__r) {

                    pspattendees.add(new PSP_Show_Attendee__c(Puppet_Show__c = ps.Id, Contact__c = c.Id));

                }
            }

        }

        try {
            insert pspattendees;
        } catch(DmlException ex) {
            System.debug(ex);
        }

    }
}