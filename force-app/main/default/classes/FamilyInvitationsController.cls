public class FamilyInvitationsController {
    
    public Campaign cam{get;set;}
    
    public Boolean multiType {get { return multiType == null ? true : multiType; }set;}
    public FamilyInvitationsController(ApexPages.StandardController sc) {
        
        if(!Test.isRunningTest())
            sc.addFields(new List<String>{'Name','RecordTypeId','RecordType.DeveloperName'});
            
        cam = (Campaign)sc.getRecord();
        
        List<Registration_Type__c> rList = new List<Registration_Type__c>([SELECT Id FROM Registration_Type__c WHERE Event__c = :cam.Id AND RecordType.DeveloperName IN ('Ticket','Aged_Camp','Volunteer', 'Volunteer_Training', 'Corporate_Volunteer')]);
        
        if(rList.isEmpty()) {
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Error: No Registration Types for Event'));
            
        } else if(rList.size() == 1) {
            
            selectedRegistration = rList[0].Id;
            multiType = false;
            registrationSelected();
        }
        
       
    }
    
    public String[] selectedFamilyType {get;set;}
    public List<SelectOption> getFamilyTypes() {
        
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Account.Family_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
        // DJA 25/11/2016 Remove Former Offspring Family
            if(f.getValue() != 'Former Patient' && f.getValue() != 'Former Offspring Family')
                result.add(new SelectOption(f.getLabel(), f.getValue()));
        }
            
        
        return result;
        
    }
    
    public String selectedRegistration {get;set;}
    public List<SelectOption> getRegistrationTypes() {
        
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('',''));
        
        for(Registration_Type__c r : [SELECT Id, Name FROM Registration_Type__c WHERE Event__c = :cam.Id AND RecordType.DeveloperName IN ('Ticket','Aged_Camp','Volunteer', 'Volunteer_Training', 'Corporate_Volunteer')])
            result.add(new SelectOption(r.Id, r.Name));
        
        return result;
        
    }
    
    public String[] selectedRegion {get;set;}
    public List<SelectOption> getRegions() {
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Account.Regionv2__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
               
        return result;
    }
    
    public String[] selectedInterest {get;set;}
    public List<SelectOption> getInterests() {
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Account.Family_Interests__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
               
        return result;
    }
    //Preferred_Event_Locations__c 
    public String[] selectedLocation {get;set;}
    public List<SelectOption> getLocations() {
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Account.Preferred_Event_Locations__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
               
        return result;
    }
    
    public String[] selectedBranch {get;set;}
    public List<SelectOption> getBranches() {
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Account.Branch_Office__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
               
        return result;
    }
    
    public String[] familyengaged {get;set;}
    public List<SelectOption> getfamilyengaged() {
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Account.Family_Engaged__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
               
        return result;
    }
    public String[] preferredLocation {get;set;}
    public List<SelectOption> getPreferredLocations() {
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Contact.Preferred_Event_Locations__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
               
        return result;
    }

    public String[] selectedSkills {get;set;}
    public List<SelectOption> getSkills() {
        List<SelectOption> result = new List<SelectOption>();
     
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Volunteer_Skill__c.Skill_Description__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
        
        return result;
    }
    
    public String selectedVolStatus {get;set;}
    public List<SelectOption> getStatus() {
        List<SelectOption> result = new List<SelectOption>();
     
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Contact.Volunteer_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
        
        return result;
    }
    
    
    public String[] selectedType {get;set;}
    public List<SelectOption> getTypes() {
        List<SelectOption> result = new List<SelectOption>();
     
        result.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Contact.Volunteer_Types__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
        
        return result;
    }
    
    public String[] selectedAttendance {get;set;}
    
    public Registration_Type__c r {get;set;}
    public Integer invited {get;set;}
    public Integer invitationsRemaining {get;set;}
    public Integer assigned {get;set;}
    public Integer remaining {get;set;}

    public void registrationSelected() {
        
        List<Registration_Type__c> rList = new List<Registration_Type__c>([SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Ticket_Type__c, Number_Available__c, Corporate_Partner__c, Corporate_Partner__r.Name, Initial_Allocation__c, Family_Ticket_Size__c, Description__c, (SELECT Id, Family__c, FA_00000__c, Pending_Members__c, Request_Members__c, Accepted_Members__c, Attended_Members__c FROM Family_Attendances__r), (SELECT Id, Volunteer__c, Attendance__c FROM Volunteer_Attendances__r) FROM Registration_Type__c WHERE Event__c = :cam.Id AND Id = :selectedRegistration]);
        
        if(!rList.isEmpty()) {
            
            r = rList[0];
            
            calcRegNumbers();
            
            filterQuery();
            
            
        } else {
            
            r = null;
            familyAttendance = null;
        }
        
    }
    
    public void clearFilter() {
        
        selectedRegion = null;
        selectedLocation = null;
        selectedFamilyType = null;
        selectedInterest =  null;
        selectedAttendance = null;
        selectedBranch = null;
        preferredLocation = null;
        selectedType = null;
        selectedSkills = null;
        
        filterQuery();
    }
    
    public void filterQuery() {
        
        System.Debug('rType' + r.RecordType.DeveloperName);
        
        if(r.RecordType.DeveloperName == 'Ticket' && selectedFamilyType != null && !selectedFamilyType.isEmpty() && selectedFamilyType[0] != '') {
            
            //String query = 'SELECT Id, Name, Priority__c, Regionv2__c, Family_Interests__c, Preferred_Event_Locations__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = \'Family_Member\' ), (SELECT Id, Family__c, FA_00000__c, Request_Members__c FROM Family_Attendances__r WHERE Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\')  FROM Account WHERE Family_Type__c != \'Former Patient\' AND RecordType.DeveloperName = \'Family\'';
            // Updated DJA 6/12/2016 to include volunteer family members
            String query = 'SELECT Id, Name, Priority__c, Regionv2__c, Family_Interests__c, Preferred_Event_Locations__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c FROM Contacts WHERE (RecordType.DeveloperName = \'Family_Member\' Or RecordType.DeveloperName = \'Volunteer\')) , (SELECT Id, Family__c, FA_00000__c, Request_Members__c FROM Family_Attendances__r WHERE Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\')  FROM Account WHERE Family_Type__c != \'Former Patient\' AND RecordType.DeveloperName = \'Family\'';
            
            if(selectedRegion != null && !selectedRegion.isEmpty() && selectedRegion[0] != '') {
                query += ' AND Regionv2__c IN :selectedRegion ';
            }
            
            if(selectedLocation != null && !selectedLocation.isEmpty() && selectedLocation[0] != '') {
                query += ' AND Preferred_Event_Locations__c INCLUDES ' + campQuality.listToString(selectedLocation);
            }
            
            if(selectedFamilyType != null && !selectedFamilyType.isEmpty() && selectedFamilyType[0] != '') {
                
                System.Debug('selectedFamilyType ' + selectedFamilyType.size());
                query += ' AND Family_Type__c IN :selectedFamilyType ';
            }
                       
            if(selectedInterest != null && !selectedInterest.isEmpty() && selectedInterest[0] != '') {
                query += ' AND Family_Interests__c INCLUDES  ' + campQuality.listToString(selectedInterest);
            }
            
            if(selectedAttendance != null && !selectedAttendance.isEmpty() && selectedAttendance[0] != '') {
                
                if( selectedAttendance[0] == '--None--') {
                    query += ' AND Id NOT IN (SELECT Family__c FROM Family_Attendance__c WHERE Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\' ) ';
                    
                } else {
                    query += ' AND Id IN (SELECT Family__c FROM Family_Attendance__c WHERE FA_00000__c IN :selectedAttendance AND Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\' ) ';
                }
            }
            
            query += 'ORDER BY Priority__c DESC LIMIT 200'; //LIMIT???    
            
            System.Debug(query);
            
            List<Account> aList = Database.query(query); // new List<Account>([SELECT Id, Name, Priority__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = 'Family_Member'), (SELECT Id, FA_00000__c FROM Family_Attendances__r WHERE Event__c = :cam.Id)  FROM Account WHERE RecordType.DeveloperName = 'Family' ORDER BY Priority__c DESC]);
            
            familyAttendance = new List<fa>();
            
            for(Account a : aList) {
                
                familyAttendance.add(new fa(a));
            }
            
        } else if(r.RecordType.DeveloperName == 'Ticket') {
            
            familyAttendance = new List<fa>();
            
        } else if(r.RecordType.DeveloperName == 'Volunteer') {
            //DJA 12/12/2016 added Volunteer Status Field.
                String query = 'SELECT Id, Name, FirstName, LastName, Regionv2__c, Volunteer_Types__c, Volunteer_Status__c, Volunteer_WWC_Expiry_Date__c, Branch_Office__c, Preferred_Event_Locations__c, (SELECT Id, Attendance__c, Volunteer__c FROM Volunteer_Attendances__r WHERE Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\'), (SELECT Id, Skill_Description__c FROM Volunteer_Skills__r)  FROM Contact WHERE Volunteer_Eligible__c = \'Eligible\' AND RecordType.DeveloperName = \'Volunteer\'';
                
                
                if(selectedRegion != null && !selectedRegion.isEmpty() && selectedRegion[0] != '') {
                    query += ' AND Regionv2__c IN :selectedRegion ';
                }
                
                if(selectedBranch != null && !selectedBranch.isEmpty() && selectedBranch[0] != '') {
                    query += ' AND Branch_Office__c IN :selectedBranch ';
                }
                
                if(preferredLocation != null && !preferredLocation.isEmpty() && preferredLocation[0] != '') {
                    query += ' AND Preferred_Event_Locations__c INCLUDES ' + campQuality.listToString(preferredLocation);
                }
                
                if(selectedType != null && !selectedType.isEmpty() && selectedType[0] != '') {
                    query += ' AND Volunteer_Types__c INCLUDES ' + campQuality.listToString(selectedType);
                }
                
                if(selectedSkills != null && !selectedSkills.isEmpty() && selectedSkills[0] != '') {
                    query += ' AND Id IN (SELECT Volunteer__c FROM Volunteer_Skill__c WHERE Skill_Description__c IN :selectedSkills) ';
                }
                
                
                if(selectedAttendance != null && !selectedAttendance.isEmpty() && selectedAttendance[0] != '') {
                    
                    if( selectedAttendance[0] == '--None--') {
                       query += ' AND Id NOT IN (SELECT Volunteer__c FROM Volunteer_Attendance__c WHERE Event__c = \'' + cam.Id + '\') ';
                    } else {
                        query += ' AND Id IN (SELECT Volunteer__c FROM Volunteer_Attendance__c WHERE Attendance__c IN :selectedAttendance AND Event__c = \'' + cam.Id + '\') ';
                    }
                }
                
                query += ' LIMIT 100'; //ORDER BY / LIMIT???    
                
                System.Debug(query);
                
                List<Contact> cList = Database.query(query); // new List<Account>([SELECT Id, Name, Priority__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = 'Family_Member'), (SELECT Id, FA_00000__c FROM Family_Attendances__r WHERE Event__c = :cam.Id)  FROM Account WHERE RecordType.DeveloperName = 'Family' ORDER BY Priority__c DESC]);
                
                volunteerAttendance = new List<va>();
                
                for(Contact c : cList) {
                    
                    volunteerAttendance.add(new va(c));
                }
                
                
            } else if(r.RecordType.DeveloperName == 'Volunteer_Training') {
                //Updated DJA 12/12/2016 - To Exclude Prospective vols
                String query = 'SELECT Id, Name, FirstName, LastName, Volunteer_Last_Training_Date__c, Regionv2__c, Volunteer_Types__c, Branch_Office__c, Preferred_Event_Locations__c, Volunteer_Status__c, Volunteer_WWC_Expiry_Date__c, (SELECT Id, Attendance__c, Volunteer__c FROM Volunteer_Attendances__r WHERE Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\'), (SELECT Id, Skill_Description__c FROM Volunteer_Skills__r)  FROM Contact WHERE Volunteer_Status__c != \'Prospective Volunteer\' AND Volunteer_Eligible__c != \'Former\' AND RecordType.DeveloperName = \'Volunteer\'';
                
                
                if(selectedRegion != null && !selectedRegion.isEmpty() && selectedRegion[0] != '') {
                    query += ' AND Regionv2__c IN :selectedRegion ';
                }
                
                if(selectedBranch != null && !selectedBranch.isEmpty() && selectedBranch[0] != '') {
                    query += ' AND Branch_Office__c IN :selectedBranch ';
                }
                
                if(preferredLocation != null && !preferredLocation.isEmpty() && preferredLocation[0] != '') {
                    query += ' AND Preferred_Event_Locations__c INCLUDES ' + campQuality.listToString(preferredLocation);
                }
                
                if(selectedType != null && !selectedType.isEmpty() && selectedType[0] != '') {
                    query += ' AND Volunteer_Types__c INCLUDES ' + campQuality.listToString(selectedType);
                }
                if(selectedVolStatus != null && selectedVolStatus != '') {
                    query += ' AND Volunteer_Status__c = :selectedVolStatus ';
                }
                
                if(selectedSkills != null && !selectedSkills.isEmpty() && selectedSkills[0] != '') {
                    query += ' AND Id IN (SELECT Volunteer__c FROM Volunteer_Skill__c WHERE Skill_Description__c IN :selectedSkills) ';
                }
                
                
                if(selectedAttendance != null && !selectedAttendance.isEmpty() && selectedAttendance[0] != '') {
                    
                    if( selectedAttendance[0] == '--None--') {
                       query += ' AND Id NOT IN (SELECT Volunteer__c FROM Volunteer_Attendance__c WHERE Event__c = \'' + cam.Id + '\') ';
                    } else {
                        query += ' AND Id IN (SELECT Volunteer__c FROM Volunteer_Attendance__c WHERE Attendance__c IN :selectedAttendance AND Event__c = \'' + cam.Id + '\') ';
                    }
                }
                //Update 12/12/2016 - Added sort order.
                query += ' ORDER BY Volunteer_Status__c DESC, Volunteer_Last_Training_Date__c ASC LIMIT 100'; //ORDER BY / LIMIT???    
                
                System.Debug(query);
                
                List<Contact> cList = Database.query(query); // new List<Account>([SELECT Id, Name, Priority__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = 'Family_Member'), (SELECT Id, FA_00000__c FROM Family_Attendances__r WHERE Event__c = :cam.Id)  FROM Account WHERE RecordType.DeveloperName = 'Family' ORDER BY Priority__c DESC]);
                
                volunteerAttendance = new List<va>();
                
                for(Contact c : cList) {
                    
                    volunteerAttendance.add(new va(c));
                }
                
                
            } else if(r.RecordType.DeveloperName == 'Corporate_Volunteer') {
                //DJA 12/12/2016 added Volunteer Status Field.
                String query = 'SELECT Id, Name, FirstName, LastName, Regionv2__c, Volunteer_Types__c, Volunteer_Status__c, Branch_Office__c, Preferred_Event_Locations__c, ' + 
                    ' (SELECT Id, Attendance__c, Volunteer__c FROM Volunteer_Attendances__r WHERE Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\'), ' + 
                    ' (SELECT Id, Skill_Description__c FROM Volunteer_Skills__r) ' + 
                    ' FROM Contact WHERE RecordType.DeveloperName = \'Volunteer\' AND AccountId = \'' + r.Corporate_Partner__c + '\' ';
                
                
                if(selectedRegion != null && !selectedRegion.isEmpty() && selectedRegion[0] != '') {
                    query += ' AND Regionv2__c IN :selectedRegion ';
                }
                
                if(selectedBranch != null && !selectedBranch.isEmpty() && selectedBranch[0] != '') {
                    query += ' AND Branch_Office__c IN :selectedBranch ';
                }
                
                if(preferredLocation != null && !preferredLocation.isEmpty() && preferredLocation[0] != '') {
                    query += ' AND Preferred_Event_Locations__c INCLUDES ' + campQuality.listToString(preferredLocation);
                }
                
                if(selectedType != null && !selectedType.isEmpty() && selectedType[0] != '') {
                    query += ' AND Volunteer_Types__c INCLUDES ' + campQuality.listToString(selectedType);
                }
                
                if(selectedSkills != null && !selectedSkills.isEmpty() && selectedSkills[0] != '') {
                    query += ' AND Id IN (SELECT Volunteer__c FROM Volunteer_Skill__c WHERE Skill_Description__c IN :selectedSkills) ';
                }
                
                
                if(selectedAttendance != null && !selectedAttendance.isEmpty() && selectedAttendance[0] != '') {
                    
                    if( selectedAttendance[0] == '--None--') {
                       query += ' AND Id NOT IN (SELECT Volunteer__c FROM Volunteer_Attendance__c WHERE Event__c = \'' + cam.Id + '\') ';
                    } else {
                        query += ' AND Id IN (SELECT Volunteer__c FROM Volunteer_Attendance__c WHERE Attendance__c IN :selectedAttendance AND Event__c = \'' + cam.Id + '\') ';
                    }
                }
                
                query += ' LIMIT 100'; //ORDER BY / LIMIT???    
                
                System.Debug(query);
                
                List<Contact> cList = Database.query(query); // new List<Account>([SELECT Id, Name, Priority__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = 'Family_Member'), (SELECT Id, FA_00000__c FROM Family_Attendances__r WHERE Event__c = :cam.Id)  FROM Account WHERE RecordType.DeveloperName = 'Family' ORDER BY Priority__c DESC]);
                
                volunteerAttendance = new List<va>();
                
                for(Contact c : cList) {
                    
                    volunteerAttendance.add(new va(c));
                }
                
                System.debug('volunteerAttendance: ' + volunteerAttendance);
            } else if(r.RecordType.DeveloperName == 'Aged_Camp') {
                
                //Mini Camp (1 day) -  (Children 4 - 6 years)
                //Jnr Camp (7 - 9  years) (2 night camp)
                //Middle Camp (10 - 12 years) 
                
                Set<String> fmSet = new Set<String>{'Patient','Sibling','Stepsiblin'};
                Integer ageFrom = 0;
                Integer ageTo = 0;
                if(r.Ticket_Type__c == 'Mini Camp') {
                    ageFrom = 4;
                    ageTo = 6;
                } else if(r.Ticket_Type__c == 'Jnr Camp') {
                    ageFrom = 6;
                    ageTo = 9;
                } else if(r.Ticket_Type__c == 'Middle Camp') {
                    ageFrom = 10;
//                    ageTo = 12;
                    //DJA 24/11/2016
                    ageTo = 13;
                }
                else if(r.Ticket_Type__c == 'Joint Junior and Middle Camp') {
                            ageFrom = 7;
                            //DJA 20/12/2016 Update Age To to be 13.
                            ageTo = 13;
                        }
                 else if (r.Ticket_Type__c == 'Joint Mini Jun and Middle') {
                            ageFrom=4;
                            ageTo = 13;
                          }
                 else if (r.Ticket_Type__c == 'Virtual Camp') {
                           //MD 15/02/2023 - Added as new. // changed aged from 10 to 7/ Mdavis12/12/23
                            ageFrom=7;
                            ageTo = 15;    
                        }
    //added new ticket types Mdavis12/12/23

                 else if (r.Ticket_Type__c == 'Teens 13- 15') {
                            ageFrom= 13;
                            ageTo = 15;
                         }
                        
                 else if (r.Ticket_Type__c == 'Leadership 15-17') {
                            ageFrom= 15;
                            ageTo = 17;
                         }
                             

                String query = 'SELECT Id, Name, Priority__c, Regionv2__c, Family_Interests__c, Preferred_Event_Locations__c, (SELECT Id, FirstName, LastName, Year_Age__c, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = \'Family_Member\' AND Family_Member_Type__c IN :fmSet AND Year_Age__c >= :ageFrom AND Year_Age__c <= :ageTo AND npsp__Deceased__c != true AND Exclude_From_Portal__c != true), (SELECT Id, Family__c, FA_00000__c, Request_Members__c FROM Family_Attendances__r WHERE Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\')  FROM Account WHERE Family_Type__c != \'Former Patient\' AND RecordType.DeveloperName = \'Family\'';
                
            
                if(selectedRegion != null && !selectedRegion.isEmpty() && selectedRegion[0] != '') {
                    query += ' AND Regionv2__c IN :selectedRegion ';
                }
                
                if(selectedLocation != null && !selectedLocation.isEmpty() && selectedLocation[0] != '') {
                    query += ' AND Preferred_Event_Locations__c  INCLUDES ' + campQuality.listToString(selectedLocation);
                }
            
                if(selectedFamilyType != null && !selectedFamilyType.isEmpty() && selectedFamilyType[0] != '') {
                    query += ' AND Family_Type__c IN :selectedFamilyType ';
                }
            
                if(selectedInterest != null && !selectedInterest.isEmpty() && selectedInterest[0] != '') {
                    query += ' AND Family_Interests__c  INCLUDES ' + campQuality.listToString(selectedInterest);
                }
            
                if(selectedAttendance != null && !selectedAttendance.isEmpty() && selectedAttendance[0] != '') {
                    //15/2/2018 Added reg type to filter to fix combo camp issues.
                    if( selectedAttendance[0] == '--None--') {
                        query += ' AND Id NOT IN (SELECT Family__c FROM Family_Attendance__c WHERE Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\') ';  
                    } else {
                        query += ' AND Id IN (SELECT Family__c FROM Family_Attendance__c WHERE FA_00000__c IN :selectedAttendance AND Event__c = \'' + cam.Id + '\' AND Registration_Type__c = \'' + selectedRegistration + '\') ';  
                    }
                }
                
                query += 'AND Id IN (SELECT AccountId FROM Contact WHERE RecordType.DeveloperName = \'Family_Member\' AND Family_Member_Type__c IN :fmSet AND Year_Age__c >= :ageFrom AND Year_Age__c <= :ageTo AND npsp__Deceased__c != true AND Exclude_From_Portal__c != true) ORDER BY Priority__c DESC LIMIT 75'; //LIMIT???    
                
                System.Debug(query);
            
                List<Account> aList = Database.query(query); // new List<Account>([SELECT Id, Name, Priority__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = 'Family_Member'), (SELECT Id, FA_00000__c FROM Family_Attendances__r WHERE Event__c = :cam.Id)  FROM Account WHERE RecordType.DeveloperName = 'Family' ORDER BY Priority__c DESC]);
                
                familyAttendance = new List<fa>();
                
                for(Account a : aList) {
                    
                    familyAttendance.add(new fa(a));
                }
                
                
            }
        
    }
    
    public void calcRegNumbers() {
        
        invited = 0;
        invitationsRemaining = 0;
        assigned = 0;
        remaining = 0;
        
        if(r.RecordType.DeveloperName == 'Ticket') {
            
            if(r.Ticket_Type__c == 'Family') {
                for(Family_Attendance__c f : r.Family_Attendances__r) {
                    if(f.FA_00000__c != 'Declined' && f.FA_00000__c  != 'Unsuccessful' && f.FA_00000__c  != '' && f.FA_00000__c  != NULL)
                        invited += 1;
                    if(f.FA_00000__c == 'Accepted' || f.FA_00000__c == 'Attended')
                        assigned += 1;
                }
            }
            
            if(r.Ticket_Type__c == 'Individual') {
                for(Family_Attendance__c f : r.Family_Attendances__r) {
                    if(f.FA_00000__c != 'Declined' && f.FA_00000__c  != 'Unsuccessful' && f.FA_00000__c  != '' && f.FA_00000__c  != NULL)
                        invited += (Integer)f.Pending_Members__c + (Integer)f.Request_Members__c;
                    
                    if(f.FA_00000__c == 'Accepted' || f.FA_00000__c == 'Attended')
                        assigned += (Integer)f.Accepted_Members__c + (Integer)f.Attended_Members__c;
                }
            }
            
        } else if(r.RecordType.DeveloperName == 'Aged_Camp') {
        
            for(Family_Attendance__c f : r.Family_Attendances__r) {
                if(f.FA_00000__c != 'Declined' && f.FA_00000__c  != 'Unsuccessful' && f.FA_00000__c  != '' && f.FA_00000__c  != NULL)
                    invited += (Integer)f.Pending_Members__c + (Integer)f.Request_Members__c;
                
                if(f.FA_00000__c == 'Accepted' || f.FA_00000__c == 'Attended')
                    assigned += (Integer)f.Accepted_Members__c + (Integer)f.Attended_Members__c;
            }
            //DJA 12/12/2016 Added Volunteer Training Type
        } else if(r.RecordType.DeveloperName == 'Volunteer' || r.RecordType.DeveloperName == 'Volunteer_Training') {
            
            for(Volunteer_Attendance__c v : r.Volunteer_Attendances__r) {
                if(v.Attendance__c != 'Declined' && v.Attendance__c  != 'Unsuccessful' && v.Attendance__c  != '' && v.Attendance__c  != NULL)
                    invited += 1;
                if(v.Attendance__c == 'Accepted' || v.Attendance__c == 'Attended')
                    assigned += 1;
            }
            
        }
        
        if(r.Initial_Allocation__c == null)
            r.Initial_Allocation__c = 0;
        
        invitationsRemaining = (Integer)r.Initial_Allocation__c - invited;
        
        if(r.Number_Available__c == null)
            r.Number_Available__c = 0;
        
        remaining = (Integer)r.Number_Available__c - assigned;
        
    }
    
    public List<fa> familyAttendance {get;set;}
    
    public class fa {
        
       
        transient public Account family {get;set;}
        public Integer familySize {get;set;}
        public Family_Attendance__c attendance {get;set;}
        
        public fa(Account a) {
            
            this.family = a;
            this.familySize = a.Contacts.size();
            
            if(a.Family_Attendances__r.isEmpty()) {

                this.attendance = new Family_Attendance__c( Family__c = a.Id );
            } else {
                
                this.attendance = a.Family_Attendances__r[0];
            }
        }
        
    }
    
     public List<va> volunteerAttendance {get;set;}
    
    public class va {
        
        
        transient public Contact contact {get;set;}
        public Volunteer_Attendance__c  attendance {get;set;}
        
        public va(Contact c) {
            
            this.contact = c;
            
            if(c.Volunteer_Attendances__r.isEmpty()) {
                
                this.attendance = new Volunteer_Attendance__c( Volunteer__c = c.Id );
            } else {
                
                this.attendance = c.Volunteer_Attendances__r[0];
            }
        }
        
    }
    
    public String selectedAttendanceValue {get;set;}
    public List<SelectOption> getAttendanceValues() {
        List<SelectOption> result = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Family_Attendance__c.FA_00000__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        result.add(new SelectOption('--None--', '--None--'));
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
               
        return result;
    }
    
    public String selectedRegisterValue {get;set;}
    public List<SelectOption> getRegisterValues() {
        List<SelectOption> result = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Volunteer_Attendance__c.Attendance__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
            result.add(new SelectOption(f.getLabel(), f.getValue()));
               
        return result;
    }
    
    public void process() {
        
        System.Debug('process - ' + r.RecordType.DeveloperName);
        
        if(r.RecordType.DeveloperName == 'Ticket') {
            //ticket type
            if(r.Ticket_Type__c == 'Individual') {
                
                if(selectedAttendanceValue == 'Accepted') {
                    for(fa f : familyAttendance) {
                        
                        if(f.familySize <= remaining && f.attendance.FA_00000__c != selectedAttendanceValue) {
                            
                            f.attendance.FA_00000__c = selectedAttendanceValue;
                            assigned += (Integer)f.attendance.Request_Members__c;
                            remaining -= (Integer)f.attendance.Request_Members__c;
                            
                        } else {
                            break;
                        }
                    }
                }
                
                if(selectedAttendanceValue == 'Invited' || selectedAttendanceValue == 'Request to Attend') {
                    for(fa f : familyAttendance) {
                        
                        if(f.familySize <= invitationsRemaining && f.attendance.FA_00000__c != selectedAttendanceValue) {
                            
                            f.attendance.FA_00000__c = selectedAttendanceValue;
                            invited += f.familySize;
                            invitationsRemaining -= f.familySize;
                        } else {
                            break;
                        }
                    }
                }
                
            } else if(r.Ticket_Type__c == 'Family') {
                
                //for each family, assign a ticket allocation
                
                if(selectedAttendanceValue == 'Accepted') {
                    for(fa f : familyAttendance) {
                        if(remaining > 0 && f.attendance.FA_00000__c != selectedAttendanceValue) {
                            
                            f.attendance.FA_00000__c = selectedAttendanceValue;
                            assigned += 1;
                            remaining -= 1; 
                        } else {
                            break;
                        }
                    }
                }
                
                if(selectedAttendanceValue == 'Invited' || selectedAttendanceValue == 'Request to Attend') {
                    for(fa f : familyAttendance) {
                        if(invitationsRemaining > 0 && f.attendance.FA_00000__c != selectedAttendanceValue) {
                            
                            f.attendance.FA_00000__c = selectedAttendanceValue;
                            invited +=1;
                            invitationsRemaining -= 1;
                        } else {
                            break;
                        }
                    }
                }
                
            }
        } else if(r.RecordType.DeveloperName == 'Aged_Camp') {
            
             if(selectedAttendanceValue == 'Accepted') {
                    for(fa f : familyAttendance) {
                        
                        if(f.familySize <= remaining && f.attendance.FA_00000__c != selectedAttendanceValue) {
                            
                            f.attendance.FA_00000__c = selectedAttendanceValue;
                            assigned += (Integer)f.attendance.Request_Members__c;
                            remaining -= (Integer)f.attendance.Request_Members__c;
                        } else {
                            break;
                        }
                    }
                }
                
                if(selectedAttendanceValue == 'Invited' || selectedAttendanceValue == 'Request to Attend') {
                    for(fa f : familyAttendance) {
                        
                        System.Debug(invitationsRemaining);
                        
                        if(f.familySize <= invitationsRemaining && f.attendance.FA_00000__c != selectedAttendanceValue) {
                            
                            f.attendance.FA_00000__c = selectedAttendanceValue;
                            invited += f.familySize;
                            invitationsRemaining -= f.familySize;
                        } else {
                            break;
                        }
                    }
                }
            //DJA 12/12/2016 Added Volunteer_Training
        } else if(r.RecordType.DeveloperName == 'Volunteer' || r.RecordType.DeveloperName == 'Volunteer_Training' || r.RecordType.DeveloperName == 'Corporate_Volunteer') {
            
            if(selectedRegisterValue == 'Accepted') {
                for(va v : volunteerAttendance) {
                    if(remaining > 0 && v.attendance.Attendance__c != selectedRegisterValue) {
                        
                        v.attendance.Attendance__c = selectedRegisterValue;
                        assigned +=1;
                        remaining -= 1;
                    } else {
                        break;
                    }
                }
            }
            
            if(selectedRegisterValue == 'Invited' || selectedAttendanceValue == 'Request to Attend') {
                for(va v : volunteerAttendance) {
                    if(invitationsRemaining > 0 && v.attendance.Attendance__c != selectedRegisterValue) {
                        
                        v.attendance.Attendance__c = selectedRegisterValue;
                        invited +=1;
                        invitationsRemaining -= 1;
                    } else {
                        break;
                    }
                }
            }
        }
        
        reloadTransientData();
        
    }
    
    public void reloadTransientData() {
        
        if(r.RecordType.DeveloperName == 'Ticket') {
            
            Set<Id> aSet = new Set<Id>();
            
            for(fa a : familyAttendance)
                aSet.add(a.attendance.Family__c);

            Map<Id, Account> aMap = new Map<Id, Account>([SELECT Id, Name, Priority__c, Regionv2__c, Family_Interests__c, Preferred_Event_Locations__c, (SELECT Id, FirstName, LastName, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = 'Family_Member') FROM Account WHERE Id IN :aSet]);
            
            for(fa a : familyAttendance) {
                if(aMap.containsKey(a.attendance.Family__c))
                    a.family = aMap.get(a.attendance.Family__c);
            }

        } else if(r.RecordType.DeveloperName == 'Aged_Camp') {
            
            Set<String> fmSet = new Set<String>{'Patient','Sibling','Stepsibling'};
                Integer ageFrom = 0;
            Integer ageTo = 0;
            if(r.Ticket_Type__c == 'Mini Camp') {
                ageFrom = 4;
                ageTo = 6;
            } else if(r.Ticket_Type__c == 'Jnr Camp') {
                ageFrom = 6;
                ageTo = 9;
            } else if(r.Ticket_Type__c == 'Middle Camp') {
                ageFrom = 10;
                //DJA 24/11/2016
                ageTo = 13;
            }
             else if(r.Ticket_Type__c == 'Joint Junior and Middle Camp') {
                            ageFrom = 7;
                            //DJA 20/12/2016 Update Age To to be 13.
                            ageTo = 13;
                        }
                 else if (r.Ticket_Type__c == 'Joint Mini Jun and Middle') {
                            ageFrom=4;
                            ageTo = 13;
                         }
                 else if (r.Ticket_Type__c == 'Virtual Camp') {
                            ageFrom=7;
                            // changed aged from 10 to 7/ Mdavis12/12/23
                            ageTo = 15;  
                        }
                        //added new ticket types Mdavis12/12/23
                 else if (r.Ticket_Type__c == 'Teens 13- 15') {
                            ageFrom= 13;
                            ageTo = 15;
                         }
                        
                 else if (r.Ticket_Type__c == 'Leadership 15-17') {
                            ageFrom= 15;
                            ageTo = 17;
                         }
            
            
            Set<Id> aSet = new Set<Id>();
            
            for(fa a : familyAttendance)
                aSet.add(a.attendance.Family__c);

            Map<Id, Account> aMap = new Map<Id, Account>([SELECT Id, Name, Priority__c, Regionv2__c, Family_Interests__c, Preferred_Event_Locations__c, (SELECT Id, FirstName, LastName, Year_Age__c, Family_Member_Type__c FROM Contacts WHERE RecordType.DeveloperName = 'Family_Member' AND Family_Member_Type__c IN :fmSet AND Year_Age__c >= :ageFrom AND Year_Age__c <= :ageTo AND npsp__Deceased__c != true AND Exclude_From_Portal__c != true) FROM Account WHERE Id IN :aSet]);
            
            for(fa a : familyAttendance) {
                if(aMap.containsKey(a.attendance.Family__c))
                    a.family = aMap.get(a.attendance.Family__c);
            }
        
        } else if(r.RecordType.DeveloperName == 'Volunteer' || r.RecordType.DeveloperName == 'Volunteer_Training' || r.RecordType.DeveloperName == 'Corporate_Volunteer') {
              
            Set<Id> cSet = new Set<Id>();
            
            for(va a : volunteerAttendance)
                cSet.add(a.attendance.Volunteer__c);
//Updated DJA 12/12/2017
            Map<Id, Contact> cMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Regionv2__c, Volunteer_Status__c, Volunteer_Types__c, Branch_Office__c, Preferred_Event_Locations__c, Volunteer_WWC_Expiry_Date__c, Volunteer_Last_Training_Date__c, (SELECT Id, Skill_Description__c FROM Volunteer_Skills__r)  FROM Contact WHERE Id IN :cSet]);
            
            for(va a : volunteerAttendance) {
                if(cMap.containsKey(a.attendance.Volunteer__c))
                    a.contact = cMap.get(a.attendance.Volunteer__c);
            }
            
        }
        
          
    }
    
    public pageReference saveClose() {
        
        processSave();
        
        pageReference pageRef = new pageReference('/' + cam.Id);
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    public void save() {
        
        processSave();
        
        filterQuery();
    }
    
    public void processSave() {
        
        try {
            
            if(r.RecordType.DeveloperName == 'Ticket') {
                
                List<Family_Attendance__c> faUpsert = new List<Family_Attendance__c>();
                
                for(fa a : familyAttendance) {
                    
                    if(a.attendance.Id == null) {

                        a.attendance.Event__c = cam.Id;
                    }
                    
                    if((a.attendance.FA_00000__c != null && a.attendance.FA_00000__c != '') || a.attendance.Id != null) {
                        
                        a.attendance.Registration_Type__c = r.Id;
                        
                        faUpsert.add(a.attendance);
                    }
                }
                
                try {
                
                    if(!faUpsert.isEmpty())
                        upsert faUpsert;
                
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Success: Family Attendance Saved. '));
                
                } catch(Exception e) {
                    System.Debug(e);    
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));
                }
                    
            } else if(r.RecordType.DeveloperName == 'Aged_Camp') {
                
                List<Family_Attendance__c> faUpsert = new List<Family_Attendance__c>();
                
                for(fa a : familyAttendance) {
                    
                    if(a.attendance.Id == null) {

                        a.attendance.Event__c = cam.Id;
                    }
                    
                    if((a.attendance.FA_00000__c != null && a.attendance.FA_00000__c != '') || a.attendance.Id != null) {
                        
                        a.attendance.Registration_Type__c = r.Id;
                        
                        faUpsert.add(a.attendance);
                    }
                }
                
                try {
                    
                    if(!faUpsert.isEmpty())
                        upsert faUpsert;
                    
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Success: Family Attendance Saved. '));
                    
                } catch(Exception e) {
                    System.Debug(e);    
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));
                }
                    //DJA 12/12/2016 Add Volunteer_Training
            } else if(r.RecordType.DeveloperName == 'Volunteer' || r.RecordType.DeveloperName == 'Volunteer_Training' || r.RecordType.DeveloperName == 'Corporate_Volunteer') {
                
                  
                List<Volunteer_Attendance__c> vaUpsert = new List<Volunteer_Attendance__c>();
                
                for(va c : volunteerAttendance) {
                    
                    if(c.attendance.Id == null) {

                        c.attendance.Event__c = cam.Id;
                    }
                    
                    if((c.attendance.Attendance__c != null && c.attendance.Attendance__c != '') || c.attendance.Id != null) {
                        
                        c.attendance.Registration_Type__c = r.Id;
                        
                        vaUpsert.add(c.attendance);
                    }
                }
                
                try {
                
                    // Commented by Amit Yadav : 05/19/2023 : DML_ISSUE : APEX CPU TIME LIMIT EXCEED
                    /*if(!vaUpsert.isEmpty())
                        upsert vaUpsert; */
                    // Added by Amit Yadav : 05/19/2023
                    if(!vaUpsert.isEmpty() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                        System.enqueueJob(new FamilyInvitationsHelper(vaUpsert, 'Upsert'));
                    }
                    
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Success: Volunteer Attendance Saved. '));
                    
                } catch(Exception e) {
                    System.Debug(e);    
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));
                }
            }
            
            calcRegNumbers();
            
        } catch (Exception e) {
            System.debug(e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));
        }
        
    }
    
    
}