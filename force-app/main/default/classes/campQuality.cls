global class campQuality {

    public static Boolean inTriggerContext { get { return inTriggerContext == null ? false : inTriggerContext; } set; }
    
    public static void familtAttendanceCampaignMember(Set<Id> faSet) {

        
        List<Family_Attendance__c> fas = [SELECT Id, FA_00000__c, Event__c, Family__c, Family__r.npe01__One2OneContact__c,
                                         (SELECT Id, Attendance__c, Status, Family_Attendance__c, Family_Attendance__r.FA_00000__c FROM Campaign_Members__r) 
                                         FROM Family_Attendance__c 
                                         WHERE Id IN :faSet];

        List<CampaignMember> upsertList = new List<CampaignMember>();

        for(Family_Attendance__c fa : fas) {

            if(!fa.Campaign_Members__r.isEmpty()) {
                CampaignMember cm = fa.Campaign_Members__r[0];

                if(cm.Attendance__c != cm.Family_Attendance__r.FA_00000__c) {
             
                    cm.Attendance__c = cm.Family_Attendance__r.FA_00000__c;
                    cm.Status = attendanceStatusEquivalent(cm.Attendance__c);
                    upsertList.add(cm);
                }
            } else {
                upsertList.add(new CampaignMember(Family_Attendance__c = fa.Id, Attendance__c = fa.FA_00000__c, Status = attendanceStatusEquivalent(fa.FA_00000__c), CampaignId = fa.Event__c, ContactId = fa.Family__r.npe01__One2OneContact__c));
            }

        }
        
        if(!upsertList.isEmpty()) {
            List<Database.UpsertResult> results = Database.upsert(upsertList, CampaignMember.fields.Id, false);

            for(Database.UpsertResult ur : results) {
                if(!ur.isSuccess()) {
                    for(Database.Error err : ur.getErrors()) {
                        System.debug('Error saving Campaign Member: ' + err.getStatusCode() + ': ' + err.getMessage());
                    }

                }
            }
        }
        
    }
    
    
    public static void familyMemberAttendance(List<Family_Attendance__c> faList) {
        
        Set<Id> aSet = new Set<Id>();
        Set<Id> rSet = new Set<Id>();

        for(Family_Attendance__c fa : faList) {
            aSet.add(fa.Family__c);
            rSet.add(fa.Registration_Type__c);
        }
        
        Map<Id, Registration_Type__c> rMap = new Map<Id, Registration_Type__c>([SELECT Id, Ticket_Type__c
                                                                                FROM Registration_Type__c
                                                                                WHERE Id IN :rSet
                                                                                AND RecordType.DeveloperName = 'Aged_Camp']);
        
        List<Family_Member_Attendance__c> fmaInsert = new List<Family_Member_Attendance__c>();
        

        //All Family Members
        //Updated DJA 18/11/2016 to included volunteer members.
        Map<Id, Account> aMap = new Map<Id, Account>([SELECT Id, npe01__One2OneContact__c, (SELECT Id, Year_Age__c, Family_Member_Type__c
                                                                                            FROM Contacts
                                                                                            WHERE (RecordType.DeveloperName = 'Family_Member'
                                                                                            OR RecordType.DeveloperName = 'Volunteer')
                                                                                            AND npsp__Deceased__c != TRUE
                                                                                            AND Exclude_From_Portal__c  != true
                                                                                            )
                                                        FROM Account
                                                        WHERE Id IN :aSet
                                                        AND RecordType.DeveloperName = 'Family'
                                                        ]);
        
        Map<Id, Family_Attendance__c> primaryMap = new Map<Id, Family_Attendance__c>();
        
        for(Family_Attendance__c fa : faList) {
            
            if(aMap.containsKey(fa.Family__c)) {
                
                primaryMap.put(aMap.get(fa.Family__c).npe01__One2OneContact__c, fa);
                
                for(Contact c : aMap.get(fa.Family__c).Contacts) {
                    
                    if(!rMap.containsKey(fa.Registration_Type__c)) {
                    
                        Family_Member_Attendance__c fma = new Family_Member_Attendance__c();
                        
                        fma.Family_Attendance__c = fa.Id;
                        fma.Contact__c = c.Id;
                        fma.Attendance__c = fa.FA_00000__c;
                        
                        fmaInsert.add(fma);
                        
                    } else {
                        //Aged
                        Integer ageFrom = 0;
                        Integer ageTo = 0;
                        if(rMap.get(fa.Registration_Type__c).Ticket_Type__c == 'Mini Camp') {
                            ageFrom = 4;
                            ageTo = 6;
                        } else if(rMap.get(fa.Registration_Type__c).Ticket_Type__c == 'Jnr Camp') {
                            ageFrom = 6;
                              //MD 15/02/2023 Update Age from 7 to 6
                            ageTo = 9;
                        } else if(rMap.get(fa.Registration_Type__c).Ticket_Type__c == 'Middle Camp') {
                            ageFrom = 10;
                            //DJA 20/12/2016 Update Age To to be 13.
                            ageTo = 13;
                        }
                        else if(rMap.get(fa.Registration_Type__c).Ticket_Type__c == 'Joint Junior and Middle Camp') {
                            ageFrom = 7;
                            //DJA 20/12/2016 Update Age To to be 13.
                            ageTo = 13;
                        }
                        else if (rMap.get(fa.Registration_Type__c).Ticket_Type__c == 'Joint Mini Jun and Middle') {
                            ageFrom=4;
                            ageTo = 13;
                            }
                        else if (rMap.get(fa.Registration_Type__c).Ticket_Type__c == 'Virtual Camp') {
                            //MD 15/02/2023 - Added as new. // changed aged from 10 to 7/ Mdavis12/12/23
                            ageFrom=7;
                            ageTo = 15;
                            }
   //added new ticket types Mdavis12/12/23
                        else if(rMap.get(fa.Registration_Type__c).Ticket_Type__c == 'Teens 13- 15') {
                            ageFrom= 13;
                            ageTo = 15;
                         }
                        else if(rMap.get(fa.Registration_Type__c).Ticket_Type__c == 'Leadership 15-17') {
                            ageFrom= 15;
                            ageTo = 17;
                         }
                        
                        if((c.Family_Member_Type__c == 'Patient' || c.Family_Member_Type__c == 'Sibling' || c.Family_Member_Type__c == 'Stepsibling')
                           && (c.Year_Age__c >= ageFrom && c.Year_Age__c <= ageTo)){
                            
                           Family_Member_Attendance__c fma = new Family_Member_Attendance__c();
                           
                           fma.Family_Attendance__c = fa.Id;
                           fma.Contact__c = c.Id;
                           fma.Attendance__c = fa.FA_00000__c;
                           
                            fmaInsert.add(fma);
                        }
                    }
                }
            }
        }
        
        if(!fmaInsert.isEmpty())
            insert fmaInsert;
        
        //Campaign Members
        List<CampaignMember> cmList = new List<CampaignMember>();
        
        for(Id p : primaryMap.keySet()) {
            
            CampaignMember cm = new CampaignMember();
            
            cm.ContactId = p;
            cm.CampaignId = primaryMap.get(p).Event__c;
            cm.Family_Attendance__c = primaryMap.get(p).Id;
                
            cmList.add(cm);
        }
            
        if(!cmList.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(cmList, false);

            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error saving Campaign Member: ' + err.getStatusCode() + ': ' + err.getMessage());
                    }

                }
            }
        }
    }
    
   /* public static void familyMemberAttendanceUpdate(Set<Id> faSet) {
        
        if(!faSet.isEmpty()) {
            
            List<Family_Attendance__c> faList = new List<Family_Attendance__c>([SELECT Id, FA_00000__c, (SELECT Id, Attendance__c FROM Family_Member_Attendance__r) FROM Family_Attendance__c WHERE Id IN :faSet]);
            List<Family_Member_Attendance__c> fmaUpdate = new List<Family_Member_Attendance__c>();
            
            for(Family_Attendance__c fa : faList) {
                for(Family_Member_Attendance__c fma : fa.Family_Member_Attendance__r) {
                    if(fma.Attendance__c != 'Cancelled' && fma.Attendance__c != 'Declined' && fma.Attendance__c != 'Unsuccessful') {
                        fma.Attendance__c = fa.FA_00000__c;
                        fmaUpdate.add(fma);    
                    }
                }
            }
            update fmaUpdate;
        }
    }*/
    
    public static void familyAttendanceUpdate(Set<Id> faSet) {
        
        if(!faSet.isEmpty()) {
            
            List<Family_Attendance__c> faList = new List<Family_Attendance__c>([SELECT Id, FA_00000__c, (SELECT Id, Attendance__c FROM Family_Member_Attendance__r) FROM Family_Attendance__c WHERE Id IN :faSet]);
            List<Family_Attendance__c> faUpdateList = new List<Family_Attendance__c>();
            
            for(Family_Attendance__c fa : faList) {
                
                String updatedStatus = null;
                Integer statusRank = 0;
                
                //Status Heiracry
                //Attended
                //Accepted
                //Request to Attend
                //Invited
                //Declined & Other
                
                for(Family_Member_Attendance__c fma : fa.Family_Member_Attendance__r) {
                    
                    if(fma.Attendance__c == 'Attended') {
                        updatedStatus = fma.Attendance__c;
                        statusRank = 5;
                    } else if(fma.Attendance__c == 'Accepted' && statusRank < 4) {
                        updatedStatus = fma.Attendance__c;
                        statusRank = 4;
                    } else if(fma.Attendance__c == 'Request to Attend' && statusRank < 3) {
                        updatedStatus = fma.Attendance__c;
                        statusRank = 3;
                    } else if(fma.Attendance__c == 'Invited' && statusRank < 2) {
                        updatedStatus = fma.Attendance__c;
                        statusRank = 2;
                    } else if(statusRank == 0) {
                        updatedStatus = fma.Attendance__c;
                    }
                }
                
                if(updatedStatus != fa.FA_00000__c) {
                    fa.FA_00000__c = updatedStatus;
                    faUpdateList.add(fa);
                }
            }
            
            if(!faUpdateList.isEmpty())
                update faUpdateList;
        }
    }
    
    public static void familyMemberRollup(Set<Id> aSet) {
        
        if(!aSet.isEmpty()) {
            
            List<Account> aList = new List<Account>([SELECT Id, Patients_in_Family__c,  Children_under_13__c, (SELECT Id, Age__c, Is_Patient__c, Family_Member_Type__c FROM Contacts WHERE (RecordType.DeveloperName = 'Family_Member' or RecordType.DeveloperName = 'Volunteer') AND npsp__Deceased__c != true AND Exclude_From_Portal__c  != true) FROM Account WHERE Id IN :aSet AND RecordType.DeveloperName = 'Family']);
            
            System.Debug(aList);
            
            for(Account a : aList) {
             
                a.Patients_in_Family__c = 0;
                a.Children_under_13__c = 0;
                
                for(Contact c : a.Contacts) {
                    if(c.Family_Member_Type__c == 'Patient' ||  c.Is_Patient__c  == 'Yes')
                        a.Patients_in_Family__c += 1;
                    
                    if(c.Age__c < 13)
                        a.Children_under_13__c += 1;
                }
            }
            
            try {
                update aList;
            } catch(Exception e) {   
                System.debug('Member RollUp Issue ' + e);
            }
        }
    }
    
    public static void attendanceRollup(Set <Id> aSet) {
        
        if(!aSet.isEmpty()) {
            
            Map<Id, RecordType> rMap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Campaign' AND (DeveloperName = 'Family_Camp' OR DeveloperName = 'Family_Experience' OR DeveloperName = 'Family_Fun_Day' OR DeveloperName = 'Age_Camp')]);
            
            System.Debug(rMap);
            
            List<Account> aList = new List<Account>([SELECT Id, Family_Camp__c, Family_Experience__c, Family_Fun_Day__c, Aged_Camp__c, 
                                                     Family_Camps_12__c, Family_Camps_1_2__c, Family_Camps_2__c, Family_Experiences_12__c, Family_Experiences_1_2__c, Family_Experiences_2__c, 
                                                     Family_Fun_Days_12__c, Family_Fun_Days_1_2__c, Family_Fun_Days_2__c, Aged_Camps_12__c, Aged_Camps_1_2__c, Aged_Camps_2__c, 
                                                     Programs_Attended__c, Last_Program_Attended__c, No_Show_Count__c,Unsuccessful_Last_12_Months__c, 
                                                     (SELECT Id, Event__r.StartDate, Event__r.RecordType.DeveloperName, FA_00000__c FROM Family_Attendances__r WHERE (FA_00000__c = 'Attended' OR FA_00000__c = 'No Show' OR FA_00000__c = 'Unsuccessful'  OR FA_00000__c = 'Unsuccessful – Waitlist' OR  FA_00000__c = 'Unsuccessful – Declined')   AND Event__r.StartDate != NULL) 
                                                     FROM Account WHERE Id IN :aSet]);
            
            System.Debug(aList);
            
            for(Account a : aList) {
                
                a.Family_Camp__c = null; 
                a.Family_Experience__c = null;
                a.Family_Fun_Day__c = null;
                a.Aged_Camp__c = null;
                a.Other_Event__c = null;
                a.Last_Program_Attended__c = null;
                
                a.Family_Camps_12__c = 0;
                a.Family_Camps_1_2__c = 0;
                a.Family_Camps_2__c = 0;
                a.Family_Experiences_12__c = 0;
                a.Family_Experiences_1_2__c = 0;
                a.Family_Experiences_2__c = 0;
                a.Family_Fun_Days_12__c = 0;
                a.Family_Fun_Days_1_2__c = 0;
                a.Family_Fun_Days_2__c = 0;
                a.Aged_Camps_12__c = 0;
                a.Aged_Camps_1_2__c = 0;
                a.Aged_Camps_2__c = 0;
                a.Other_Events_12__c = 0;
                a.Other_Events_1_2__c = 0;
                a.Other_Events_2__c = 0;
                a.No_Show_Count__c = 0;
                a.Unsuccessful_Last_12_Months__c = 0;

                a.Programs_Attended__c = 0; 
                
                System.Debug(a.Family_Attendances__r);
                
                for(Family_Attendance__c fa : a.Family_Attendances__r) {
                    
                    System.Debug(fa.Event__r.RecordTypeId);
                    //DJA 26/08/2019 Added unsuccessful and No Show Counts
                   if(fa.FA_00000__c == 'Unsuccessful'  || fa.FA_00000__c == 'Unsuccessful – Waitlist' ||  fa.FA_00000__c == 'Unsuccessful – Declined')
                   {
                        if(fa.Event__r.StartDate > System.Today().addMonths(-12))
                            a.Unsuccessful_Last_12_Months__c +=1;
                       
                   }
                    if(fa.FA_00000__c == 'No Show')
                   {
                        if(fa.Event__r.StartDate > System.Today().addMonths(-36))
                            a.No_Show_Count__c +=1;
                       
                   }
                    
                    if(fa.FA_00000__c == 'Attended') {
                        a.Programs_Attended__c++;
                        if(a.Last_Program_Attended__c == null || a.Last_Program_Attended__c < fa.Event__r.StartDate) {
                            a.Last_Program_Attended__c = fa.Event__r.StartDate;
                        }
                        
                        
                        if(fa.Event__r.RecordType.DeveloperName == 'Family_Camp') {
                            
                            if(a.Family_Camp__c == NULL || fa.Event__r.StartDate > a.Family_Camp__c)
                                a.Family_Camp__c = fa.Event__r.StartDate;
                            
                            if(fa.Event__r.StartDate > System.Today().addMonths(-12))
                                a.Family_Camps_12__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-12) && fa.Event__r.StartDate > System.Today().addMonths(-24))
                                a.Family_Camps_1_2__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-24))
                                a.Family_Camps_2__c += 1;
                            
                            System.Debug(a.Family_Camp__c);
                        } else if(fa.Event__r.RecordType.DeveloperName == 'Family_Experience') {
                            
                            if(a.Family_Experience__c == NULL || fa.Event__r.StartDate > a.Family_Experience__c)
                                a.Family_Experience__c = fa.Event__r.StartDate;
                            
                            if(fa.Event__r.StartDate > System.Today().addMonths(-12))
                                a.Family_Experiences_12__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-12) && fa.Event__r.StartDate > System.Today().addMonths(-24))
                                a.Family_Experiences_1_2__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-24))
                                a.Family_Experiences_2__c += 1;
                            
                            System.Debug(a.Family_Experience__c);
                        } else if(fa.Event__r.RecordType.DeveloperName == 'Family_Fun_Day') {
                            
                            if(a.Family_Fun_Day__c == NULL || fa.Event__r.StartDate > a.Family_Fun_Day__c)
                                a.Family_Fun_Day__c = fa.Event__r.StartDate;
                            
                            if(fa.Event__r.StartDate > System.Today().addMonths(-12))
                                a.Family_Fun_Days_12__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-12) && fa.Event__r.StartDate > System.Today().addMonths(-24))
                                a.Family_Fun_Days_1_2__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-24))
                                a.Family_Fun_Days_2__c += 1;
                            
                            System.Debug(a.Family_Fun_Day__c);
                        } else if(fa.Event__r.RecordType.DeveloperName == 'Age_Camp') {
                            
                            if(a.Aged_Camp__c == NULL || fa.Event__r.StartDate > a.Aged_Camp__c)
                                a.Aged_Camp__c = fa.Event__r.StartDate;
                            
                            if(fa.Event__r.StartDate > System.Today().addMonths(-12))
                                a.Aged_Camps_12__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-12) && fa.Event__r.StartDate > System.Today().addMonths(-24))
                                a.Aged_Camps_1_2__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-24))
                                a.Aged_Camps_2__c += 1;
                            
                            System.Debug(a.Aged_Camp__c);
                        } else if(fa.Event__r.RecordType.DeveloperName != 'Volunteer') {
    
                            if(a.Other_Event__c == NULL || fa.Event__r.StartDate > a.Other_Event__c)
                                a.Other_Event__c = fa.Event__r.StartDate;
                            
                            if(fa.Event__r.StartDate > System.Today().addMonths(-12))
                                a.Other_Events_12__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-12) && fa.Event__r.StartDate > System.Today().addMonths(-24))
                                a.Other_Events_1_2__c += 1;
                            else if(fa.Event__r.StartDate < System.Today().addMonths(-24))
                                a.Other_Events_2__c += 1;
    
                        }
                    }
                }   
            }
            try {   
                update aList;
            } catch(Exception e) {
                System.debug('Attendance RollUp Issue ' + e);
            }   
        }
    }

    public static void puppetShowRollup(Set<Id> aSet) {
        if(!aSet.isEmpty()) {

            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Puppet_Show__c, Puppet_Shows_12__c, Puppet_Shows_2__c, Puppet_Shows_1_2__c FROM Account WHERE Id IN :aSet]);
            
            List<Contact> cList = [SELECT Id, AccountId,
                                  (SELECT Id, Puppet_Show__r.Show_Date__c FROM PSP_Show_Attendees__r WHERE Puppet_Show__r.Show_Date__c != NULL) 
                                  FROM Contact WHERE AccountId IN :aSet];

            System.debug('accMap: ' + accMap);
            System.debug('cList: ' + cList);

            for(Account a : accMap.values()) {
                a.Puppet_Show__c = null; 
                a.Puppet_Shows_12__c = 0;
                a.Puppet_Shows_1_2__c = 0;
                a.Puppet_Shows_2__c = 0;
            }
            
            for(Contact c : cList) {
                if(accMap.containsKey(c.AccountId)) {
                    Account a = accMap.get(c.AccountId);

                    for(PSP_Show_Attendee__c psa : c.PSP_Show_Attendees__r) {
                        if(a.Puppet_Show__c == NULL || psa.Puppet_Show__r.Show_Date__c > a.Puppet_Show__c)
                            a.Puppet_Show__c = psa.Puppet_Show__r.Show_Date__c;
                        
                        if(psa.Puppet_Show__r.Show_Date__c > System.Today().addMonths(-12))
                            a.Puppet_Shows_12__c += 1;
                        else if(psa.Puppet_Show__r.Show_Date__c < System.Today().addMonths(-12) && psa.Puppet_Show__r.Show_Date__c > System.Today().addMonths(-24))
                            a.Puppet_Shows_1_2__c += 1;
                        else if(psa.Puppet_Show__r.Show_Date__c < System.Today().addMonths(-24))
                            a.Puppet_Shows_2__c += 1;
                    }
                }
            }
            
            try {   
                update accMap.values();
            } catch(Exception e) {
                
                System.debug('Attendance RollUp Issue ' + e);
            }
        }
    }

    public static void volunteerAttendanceRollup(Set<Id> cSet) {
        if(!cSet.isEmpty()) {
                        //Modified DJA 4/4/2017 added event_type__C and Volunteer_Last_Training_Date__c
            List<Contact> cList = [SELECT Id, AccountId, Vol_Unsuccessful_12__C, Volunteer_Attendance__c, Volunteer_Attendances_12__c, Volunteer_Last_Training_Date__c, Volunteer_Attendances_1_2__c, Volunteer_Attendances_2__c,
                                  (SELECT Id, Attendance__c, Event__r.StartDate, Event__r.event_type__c  FROM Volunteer_Attendances__r WHERE Attendance__c = 'Attended' or Attendance__c = 'Unsuccessful') 
                                  FROM Contact WHERE Id IN :cSet];

            System.debug('cList: ' + cList);

            for(Contact c : cList) {
                c.Volunteer_Attendance__c = null; 
                c.Volunteer_Attendances_12__c = 0;
                c.Volunteer_Attendances_1_2__c = 0;
                c.Volunteer_Attendances_2__c = 0;
                c.Vol_Unsuccessful_12__C = 0;
                
                for(Volunteer_Attendance__c va : c.Volunteer_Attendances__r) {
                    if (va.Attendance__c == 'Unsuccessful') {
                        if(va.Event__r.StartDate > System.Today().addMonths(-12)) {
                            c.Vol_Unsuccessful_12__C +=1;
                        }
                    }
                    
                    if (va.Attendance__c == 'Attended') { 
                        //DJA 16/7/2019 Change to 12 month 12-36 months and greater then 36 months.  And exclude non program volunteer attendances from the count.  
                        if (va.Event__r.event_type__c == 'Volunteer Leadership Induction' || va.Event__r.event_type__c == 'Volunteer Oranges' ||    va.Event__r.event_type__c == 'Volunteer Other Induction/Training' ||    va.Event__r.event_type__c == 'Volunteer Recognition Event' ||    va.Event__r.event_type__c == 'Volunteer Training Days' ||      va.Event__r.event_type__c == 'Fundraising Event'    ){
                            if (va.Event__r.event_type__c  == 'Volunteer Training Days' && (c.Volunteer_Last_Training_Date__c  == NULL || va.Event__r.StartDate > c.Volunteer_Last_Training_Date__c) )
                                c.Volunteer_Last_Training_Date__c  = va.Event__r.StartDate;
                        }
                        else {
                            if(c.Volunteer_Attendance__c == NULL || va.Event__r.StartDate > c.Volunteer_Attendance__c)
                                c.Volunteer_Attendance__c = va.Event__r.StartDate;
                            if(va.Event__r.StartDate > System.Today().addMonths(-12))
                                c.Volunteer_Attendances_12__c += 1;
                            else if(va.Event__r.StartDate < System.Today().addMonths(-12) && va.Event__r.StartDate > System.Today().addMonths(-36))
                                c.Volunteer_Attendances_1_2__c += 1;
                            else if(va.Event__r.StartDate < System.Today().addMonths(-36))
                                c.Volunteer_Attendances_2__c += 1;
                                    //Added DJA 4/4/2017
                        }   
                    }
                }
            }
            
            try {
                update cList;
            } catch(Exception e) {   
                System.debug('Attendance RollUp Issue ' + e);
            }
        }
    }

    public static void registrationTypeAllocations(Set<Id> rtIds) {
        List<Registration_Type__c> regTypes = [SELECT Id, Invited__c, Interested__c, Requested__c, Accepted__c, Attended__c, Ticket_Type__c,
                   (SELECT Id, FA_00000__c, Pending_Members__c, FamilyMemberInterestedCount__c ,Request_Members__c, Accepted_Members__c, Attended_Members__c FROM Family_Attendances__r),
                   (SELECT Id, Attendance__c FROM Volunteer_Attendances__r)
                   FROM Registration_Type__c WHERE Id IN :rtIds];
        
        for(Registration_Type__c rt : regTypes) {
            
            rt.Invited__c = 0;
            rt.Requested__c = 0;
            rt.Accepted__c = 0;
            rt.Attended__c = 0;
            rt.Interested__c = 0;
            
            if(rt.Family_Attendances__r != null) {
                for(Family_Attendance__c fa : rt.Family_Attendances__r) {
                    if(rt.Ticket_Type__c != 'Family') {
                        rt.Invited__c += fa.Pending_Members__c;
                        rt.Requested__c += fa.Request_Members__c;
                        rt.Accepted__c += fa.Accepted_Members__c;
                        rt.Attended__c += fa.Attended_Members__c;
                        rt.Interested__c += fa.FamilyMemberInterestedCount__c;
                        
                    } else if(fa.FA_00000__c == 'Invited') {
                        rt.Invited__c++;
                    } else if(fa.FA_00000__c == 'Request to Attend') {
                        rt.Requested__c++;
                        rt.Interested__c ++;
                    } else if(fa.FA_00000__c == 'Accepted') {
                        rt.Accepted__c++;
                        rt.Interested__c ++;
                    } else if(fa.FA_00000__c == 'Attended') {
                        rt.Attended__c++;
                        rt.Interested__c ++;
                    }
                    else if (fa.FA_00000__c == 'Unsuccessful' || fa.FA_00000__c == 'Cancelled') {
                       rt.Interested__c ++;
                    }
                }
            }

            if(rt.Volunteer_Attendances__r != null) {
                for(Volunteer_Attendance__c va : rt.Volunteer_Attendances__r) {
                    if(va.Attendance__c == 'Invited') {
                        rt.Invited__c++;
                    } else if(va.Attendance__c == 'Request to Attend') {
                        rt.Requested__c++;
                         rt.Interested__c ++;
                    } else if(va.Attendance__c == 'Accepted') {
                        rt.Accepted__c++;
                         rt.Interested__c ++;
                    } else if(va.Attendance__c == 'Attended') {
                        rt.Attended__c++;
                         rt.Interested__c ++;
                    }
                    else if (va.Attendance__c == 'Unsuccessful' || va.Attendance__c == 'Cancelled' ) {
                       rt.Interested__c ++;
                    }
                }
            }   
        }
        
        try {
            update regTypes;
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
    
    public static void registrationPeriodAllocations(Set<Id> rpIds) {
        //DJA 6/4/2017 - Add in Interested to this section of code.
        
        List<Registration_Period__c> regPeriods = [SELECT Id, Invited__c, Interested__c, Requested__c, Accepted__c, Attended__c,
                                                   (SELECT Id, Family_Attendance__c, Family_Attendance__r.Registration_Type__c, Family_Attendance__r.Registration_Type__r.Ticket_Type__c, Family_Attendance__r.FA_00000__c, Family_Attendance__r.Pending_Members__c, Family_Attendance__r.FamilyMemberInterestedCount__c, Family_Attendance__r.Request_Members__c, Family_Attendance__r.Accepted_Members__c, Family_Attendance__r.Attended_Members__c FROM Registration_Period_Family_Attendances__r),
                                                   (SELECT Id, Volunteer_Attendance__c, Volunteer_Attendance__r.Registration_Type__c, Volunteer_Attendance__r.Registration_Type__r.Ticket_Type__c, Volunteer_Attendance__r.Attendance__c FROM RegistrationPeriod_Volunteer_Attendances__r)
                                                   FROM Registration_Period__c WHERE Id IN :rpIds];
        
        for(Registration_Period__c rt : regPeriods) {
            
            rt.Invited__c = 0;
            rt.Requested__c = 0;
            rt.Accepted__c = 0;
            rt.Attended__c = 0;
            rt.Interested__c = 0;
            
            if(rt.Registration_Period_Family_Attendances__r != null) {
                for(Registration_Period_Family_Attendance__c fa : rt.Registration_Period_Family_Attendances__r) {
                    if(String.isNotBlank(fa.Family_Attendance__r.Registration_Type__c) && fa.Family_Attendance__r.Registration_Type__r.Ticket_Type__c != 'Family') {
                        rt.Invited__c += fa.Family_Attendance__r.Pending_Members__c;
                        rt.Requested__c += fa.Family_Attendance__r.Request_Members__c;
                        rt.Accepted__c += fa.Family_Attendance__r.Accepted_Members__c;
                        rt.Attended__c += fa.Family_Attendance__r.Attended_Members__c;
                        rt.Interested__c += fa.Family_Attendance__r.FamilyMemberInterestedCount__c;
                        
                    } else if(fa.Family_Attendance__r.FA_00000__c == 'Invited') {
                        rt.Invited__c++;
                    } else if(fa.Family_Attendance__r.FA_00000__c == 'Request to Attend') {
                        rt.Requested__c++;
                        rt.Interested__c ++;
                    } else if(fa.Family_Attendance__r.FA_00000__c == 'Accepted') {
                        rt.Accepted__c++;
                        rt.Interested__c ++;
                    } else if(fa.Family_Attendance__r.FA_00000__c == 'Attended') {
                        rt.Attended__c++;
                        rt.Interested__c ++;
                    } else if (fa.Family_Attendance__r.FA_00000__c == 'Unsuccessful' || fa.Family_Attendance__r.FA_00000__c == 'Cancelled' ) {
                        rt.Interested__c ++;  
                    }
                }
            }
            
            if(rt.RegistrationPeriod_Volunteer_Attendances__r != null) {
                for(Registration_Period_Volunteer_Attendance__c va : rt.RegistrationPeriod_Volunteer_Attendances__r) {
                    
                    if(va.Volunteer_Attendance__r.Attendance__c == 'Invited') {
                        rt.Invited__c++;
                    } else if(va.Volunteer_Attendance__r.Attendance__c == 'Request to Attend') {
                        rt.Requested__c++;
                        rt.Interested__c ++;
                    } else if(va.Volunteer_Attendance__r.Attendance__c == 'Accepted') {
                        rt.Accepted__c++;
                        rt.Interested__c ++;
                    } else if(va.Volunteer_Attendance__r.Attendance__c == 'Attended') {
                        rt.Attended__c++;
                        rt.Interested__c ++;
                    } else if(va.Volunteer_Attendance__r.Attendance__c == 'Unsuccessful' || va.Volunteer_Attendance__r.Attendance__c == 'Cancelled') {
                        rt.Interested__c ++;  
                    }
                    
                }
            }
            
        }
        
        try {
            update regPeriods;
        } catch(DmlException ex) {
            System.debug(ex);
        }
        
    }
    
    public static void volunteerEligibility(Set<Id> cIds) {
        
        List<Contact> cs = [SELECT Id, Volunteer_Eligibility__c, Volunteer_Status__c,
                            (SELECT Id, Skill_Description__c, License__c, License_No__c, Expires__c, RecordType.DeveloperName
                                FROM Volunteer_Skills__r
                                WHERE (((RecordType.DeveloperName = 'Working_With_Children_Check'
                                AND (Skill_Description__c LIKE '%WWC%' OR Skill_Description__c = 'Blue Card (QLD) Registration No & Exp Date'))
                                OR (RecordType.DeveloperName = 'Volunteer_Skill' AND (Skill_Description__c = 'Dr Indemnity Insurance Policy No/Expiry'
                                OR Skill_Description__c = 'Health Practitioner Registration No & Exp Date'
                                OR Skill_Description__c = 'First Aid'
                                OR Skill_Description__C = 'CPR')))
                                AND Expires__c > :Date.today())
                                OR (RecordType.DeveloperName = 'Working_With_Children_Check' AND Expires__c < :Date.today()) ),
                            (SELECT Id, Volunteer_Check_List__c, Date_Completed__c FROM Volunteer_Checklist__r),
                            (SELECT Id, Course__c, Course_Date__c, ACF_Course_Expiry_Date__c FROM Volunteer_Courses__r WHERE (Course__c = 'ACF Safeguarding Children' OR Course__c = 'ACF Refresh')),
                            (SELECT Id, Start_Date__c, End_Date__c, Volunteer_Status__c, Volunteer_Type__c FROM Volunteers_Type__r WHERE Volunteer_Type__c = 'Doctor' OR Volunteer_Type__c = 'Endorsed Enrolled Nurse' OR Volunteer_Type__c = 'Registered Nurse' OR Volunteer_Type__c = 'First Aider' OR Volunteer_Type__c = 'Midwife')
                            FROM Contact 
                            WHERE Id IN :cIds];
        
        System.debug('cs: ' + cs);

        List<Volunteer_Type__c> vTypes = new List<Volunteer_Type__c>();
        
        for(Contact c : cs) {
            
            Set<String> errors = new Set<String>{ 'Missing Safeguarding Children Guidelines', 'Missing SC&Y Policy', 'Missing RSCA Policy', 'Code of Conduct Form Missing', 'WWC Not Completed', 'ACF Course Not Completed'};
            Map<String, Volunteer_Type__c> vtMap = new Map<String, Volunteer_Type__c>();
            // Removed Mdavis 9/10/2023 as part of Lead Process now ('Volunteer References Missing', 'Volunteer Interview Missing', 'Photo ID Not Sighted' & added SC& Policy and RSCA Policy)
                
            if(c.Volunteers_Type__r != null && !c.Volunteers_Type__r.isEmpty()) {
                for(Volunteer_Type__c vt : c.Volunteers_Type__r) {
                    if(vt.Volunteer_Type__c == 'Doctor' || vt.Volunteer_Type__c == 'Endorsed Enrolled Nurse' || vt.Volunteer_Type__c == 'Registered Nurse'|| vt.Volunteer_Type__c == 'Midwife') {
                        errors.add('Health Practitioner Registration No & Exp Date Missing');
                            
                        if(vt.Volunteer_Type__c == 'Doctor') {
                            errors.add('Dr Indemnity Insurance Policy No/Expiry Missing');
                        }
                    }
                    
                    if(vt.Volunteer_Type__c == 'First Aider') {
                        errors.add('First Aid Missing');
                        errors.add('CPR Missing');
                    }
                    
                    vtMap.put(vt.Volunteer_Type__c, vt);
                }
            }

            if(c.Volunteer_Skills__r != null) {
                for(Volunteer_Skill__c vs : c.Volunteer_Skills__r) {
                       if(vs.Expires__c > Date.today()){
                       if(vs.RecordType.DeveloperName == 'Working_With_Children_Check' && String.isNotEmpty(vs.License__c) && String.isNotEmpty(vs.License_No__c)) {
                            errors.remove('WWC Not Completed');
                        }

                        if(vs.RecordType.DeveloperName == 'Volunteer_Skill' && String.isNotBlank(vs.Skill_Description__c)) {

                            if(vs.Skill_Description__c == 'Health Practitioner Registration No & Exp Date') {
                                errors.remove('Health Practitioner Registration No & Exp Date Missing');

                            }

                            if(vs.Skill_Description__c == 'Dr Indemnity Insurance Policy No/Expiry') {
                                errors.remove('Dr Indemnity Insurance Policy No/Expiry Missing');
                            }

                            if(vs.Skill_Description__c == 'First Aid') {
                                errors.remove('First Aid Missing');
                            }
                            if(vs.Skill_Description__c == 'CPR') {
                                errors.remove('CPR Missing');
                            }
                        }
                    } else {
                        if(vs.Expires__c < Date.today() && vs.RecordType.DeveloperName == 'Working_With_Children_Check'){
                           if(!errors.contains('WWC Not Completed'))
                            {
                                errors.add('WWC Not Completed');
                                
                            }
                            c.Volunteer_Eligibility__c = 'Pending';
                        }
                    }
                }
            }
            
            System.debug('vtMap:' + vtMap);
            System.debug('vTypes: ' + vTypes);
            
            campQuality.updateVolunteerType('Doctor', vtMap, vTypes, errors, new List<String>{'Health Practitioner Registration No & Exp Date Missing', 'Dr Indemnity Insurance Policy No/Expiry Missing'});
            campQuality.updateVolunteerType('Registered Nurse', vtMap, vTypes, errors, new List<String>{'Health Practitioner Registration No & Exp Date Missing'});
            campQuality.updateVolunteerType('Endorsed Enrolled Nurse', vtMap, vTypes, errors, new List<String>{'Health Practitioner Registration No & Exp Date Missing'});
            campQuality.updateVolunteerType('Midwife', vtMap, vTypes, errors, new List<String>{'Health Practitioner Registration No & Exp Date Missing'});
            campQuality.updateVolunteerType('First Aider', vtMap, vTypes, errors, new List<String>{'First Aid Missing','CPR Missing'});
            
            System.debug('vtMap:' + vtMap);
            System.debug('vTypes: ' + vTypes);
            
            if(c.Volunteer_Checklist__r != null) {
                for(Volunteer_Checklist__c vc : c.Volunteer_Checklist__r) {
                    if(vc.Date_Completed__c != null) {
                        //updated Code of Conduct from 2018 to 2021 version. 9/10/2023 Mdavis
                        if(vc.Volunteer_Check_List__c == 'Code of Conduct 2021') {
                            errors.remove('Code of Conduct Form Missing');
                        }
                        else if(vc.Volunteer_Check_List__c == 'Commitment to Safeguarding Children') {
                            errors.remove('Missing Safeguarding Children Guidelines');
                        }
                         else if(vc.Volunteer_Check_List__c == 'Responding to Suspected Child Abuse Policy') {
                            errors.remove('Missing RSCA Policy'); 
                        }
                         else if(vc.Volunteer_Check_List__c == 'Safeguarding Children and Young People Policy') {
                            errors.remove('Missing SC&Y Policy');
                        }
                    }
                }
            }
            //added 9/10/2023 Mdavis
           if(c.Volunteer_Courses__r != null) {
               for(Volunteer_Course__c vr : c.Volunteer_Courses__r) { 
                   if((vr.Course__c == 'ACF Safeguarding Children' || vr.Course__c == 'ACF Refresh') && vr.ACF_Course_Expiry_Date__c > Date.today()) {
                       errors.remove('ACF Course Not Completed');
                   }
               }
           }
           if(errors.size() > 0) {
               c.Volunteer_Eligibility__c = String.join(new List<String>(errors), ';');
           } else {
               c.Volunteer_Eligibility__c = 'Currently Eligible';
           }     
        }
        
        if(!vTypes.isEmpty()) {
            try {
                update vTypes;
            } catch(DmlException ex) {
                System.debug(ex);
            }
        }
        
        if(!cs.isEmpty()) {
            try {
                update cs;
            } catch(DmlException ex) {
                System.debug(ex);
            }
        }
        
    }
    
    public static void updateVolunteerType(String volType, Map<String, Volunteer_Type__c> vtMap, List<Volunteer_Type__c> vTypes, Set<String> errors, List<String> ecs) {
        if(vtMap.containsKey(volType)) {
            Volunteer_Type__c vt = vtMap.get(volType);
            Boolean conts = false;
            
            for(String ec : ecs) {
                if(errors.contains(ec)) {
                    conts = true;
                }
            }
          
            if(conts) {
                if(vt.Volunteer_Status__c == 'Active') {
                    vt.Volunteer_Status__c = 'Inactive';
                    vt.End_Date__c = Date.today();
                    vTypes.add(vt);
                }
            } else if(vt.Volunteer_Status__c != 'Active') {
                vt.Volunteer_Status__c = 'Active';
                vt.End_Date__c = null;
                vt.Start_Date__c = Date.today();
                vTypes.add(vt);
            }
        }
    }

    public static void sessionVolunteers(Set<Id> sIds) {

        List<Session__c> sessions = [SELECT Id, Volunteers_Required__c, Volunteers_Registered__c, 
                                    (SELECT Id, Volunteer_Attendance__c, Volunteer_Attendance__r.Attendance__c FROM Session_Participants__r WHERE Participant_Type__c = 'Volunteer' OR Participant_Type__c = 'Corporate Volunteer')
                                    FROM Session__c WHERE Id IN :sIds];

        if(!sessions.isEmpty()) {

            for(Session__c s : sessions) {
                s.Volunteers_Registered__c = 0;
                for(Session_Participant__c sp : s.Session_Participants__r) {
                    if(String.isNotEmpty(sp.Volunteer_Attendance__c) && (sp.Volunteer_Attendance__r.Attendance__c == 'Accepted' || sp.Volunteer_Attendance__r.Attendance__c == 'Attended')) {
                        s.Volunteers_Required__c++;
                    }
                }
            }
        }

        try {
            update sessions;
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
    
    public static String attendanceStatusEquivalent(String attend) {
        String result = '';
        
        if(attend == 'Invited') {
            result = 'Invitation to be Sent';
        } else if(attend == 'Request to Attend') {
            result = 'Requested to Attend';
        } else if(attend == 'Accepted') {
            result = 'Accepted to be Sent';
        } else if(attend == 'Attended') {
            result = 'Attended to be Sent';
        } else if(attend == 'Declined' || attend == 'Unsuccessful- Declined') {
            result = 'Declined to be Sent';
        } else if(attend == 'Unsuccessful') {
            result = 'Unsuccessful to be Sent';
        }
          else if(attend == 'Cancelled' || attend == 'Medical Withdrawal' || attend == 'No Show' || attend == 'Cancelled <24 hours') {
            result = 'Cancelled to be Sent';
        }
        
        return result;
    }
    
    public static String listToString(String[] stringSet) {
        
        String result = '';

        for(String s : stringSet) {
            
            result += '\'' + s + '\',';
        }
        
        if(result.length() > 1)
            result = '(' + result.substring(0, result.length()-1) + ')';
        
        return result;
    }
}