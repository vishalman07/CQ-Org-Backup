public class PortalContactUtility {
    private static Profile CommunityProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
    // When creating a Portal Contact, the Contact's Account Owner must have a role.
    // If this exception is caught creating a Portal Contact, and AccountOwnerWhoHasRole is set, the Contact's Account Owner will be
    // changed to this user
    private static User AccountOwnerWhoHasRole = [SELECT Id FROM User WHERE alias= '8squ' LIMIT 1]; //updated to alias lookup so it works on partial/prod no matter which email.
    
    class PortalContactUtilityException extends Exception { }
    
    public static Boolean EnablePortalContact(Id contactId) {
        if (contactId == null || String.isEmpty(contactId))
            throw new PortalContactUtilityException('No contactId given');
            
        Contact c = FindContact(contactId);
        if (c == null)
            throw new PortalContactUtilityException('Found no Contact with Id ' + contactId);
            
        List<String> contactErrors = ValidateContact(c);
        
        if (!contactErrors.isEmpty())
            throw new PortalContactUtilityException('Contact Fails Validation: ' + String.join(contactErrors, '. '));
            
        User u = CheckExistingPortalContactUser(contactId);

        System.debug('existingportalcontactuser: ' + u);
        
        if (u == null) {
            try {
                u = NewPortalContactUser(c, CommunityProfile.Id);
            } catch (Exception e) {
                throw e;
            }
        } else if(!u.IsActive) {

            u.IsActive = true;
            u.setOptions(TriggerEmailOpts());

            try {
                update u;
            } catch (Exception e) {
                throw e;
            }

            System.debug('c: ' + c);

            /*if (u.IsActive) // nothing todo
                return true;
            else {
                u.IsActive = true;
                u.setOptions(TriggerEmailOpts());
                
                try {
                    update u;
                    return true;
                } catch (Exception e) {
                    throw e;
                }
            }*/
        }   

        Set<String> neededPerms = new Set<String>();
        if (c.Portal_Access_Type__c != null && c.Portal_Access_Type__c.contains('Family Portal'))
            neededPerms.add(FamilyPermissionSet);

        if (c.Portal_Access_Type__c != null && c.Portal_Access_Type__c.contains('Volunteer Portal'))
            neededPerms.add(VolunteerPermissionSet);
        
        if (c.Portal_Access_Type__c != null && c.Portal_Access_Type__c.contains('Corporate Portal'))
            neededPerms.add(CorporateVolunteerPermissionSet);

        List<PermissionSetAssignment> psas = RemovePortalAccessAssignments(u.Id, neededPerms);
        if(!psas.isEmpty())
            delete psas;

        for (PermissionSetAssignment psa : u.PermissionSetAssignments)
            neededPerms.remove(psa.PermissionSet.Name);

        if (!neededPerms.isEmpty())
            insert PortalAccessAssignments(u.Id, new List<String>(neededPerms));

        return true;
        
    }
    
    public static Boolean DisablePortalContact(Id contactId) {
        if (contactId == null || String.isEmpty(contactId))
            throw new PortalContactUtilityException('No contactId given');
            
        Contact c = FindContact(contactId);
        
        if (c == null)
            throw new PortalContactUtilityException('Found no Contact with Id ' + contactId);
            
        List<String> contactErrors = ValidateContact(c);
        
        if (!contactErrors.isEmpty())
            throw new PortalContactUtilityException('Contact Fails Validation: ' + String.join(contactErrors, '. '));
            
        User u = CheckExistingPortalContactUser(contactId);
        
        if (u == null) {
            // User does not exist (which is better than disabled IMO!) return true.
            return true;
        } else {
            if (!u.IsActive) {
                // already disabled
                return true;
            } else {
                u.IsActive = false;
                
                try {
                    update u;
                    
                    return true;
                } catch (Exception e) {
                    throw e;
                }
            }
        }
    }
    
    private static Contact FindContact(Id contactId) {
        Contact c;
        
        try {
            c = [SELECT Id, FirstName, LastName, Email, AccountId, Portal_Access_Type__c FROM Contact WHERE Id =: contactId];
        } catch (Exception e) { }
        
        return c;
    }
    
    private static User CheckExistingPortalContactUser(Id contactId) {
        User u;
        
        try {
            u = [SELECT Id, IsActive, (SELECT PermissionSet.Name FROM PermissionSetAssignments) FROM User WHERE ContactId =: contactId];
        } catch (Exception e) { }
        
        return u;
    }
    
    private static User NewPortalContactUser(Contact c, Id profileId) {
        if (profileId == null) {
            if (CommunityProfile != null && CommunityProfile.Id != null)
                profileId = CommunityProfile.Id;
            else
                throw new PortalContactUtilityException('Misconfiguration! Cannot create Portal User without CommunityProfile');
        }
        
        List<User> checkExistingUsers;
        
        try {
            checkExistingUsers = [SELECT Id FROM User WHERE (Username =: c.Email OR Email =: c.Email) AND IsActive = true];
        } catch (Exception e) { }
        
        if (checkExistingUsers != null && !checkExistingUsers.isEmpty())
            throw new PortalContactUtilityException('There already exists a User with Email Address ' + c.Email + ' (User Record: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + checkExistingUsers[0].Id + '?noredirect=1)');
            
        User u = new User(
            IsActive=true,
            ContactId=c.Id,
            ProfileId=profileId,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_AU',
            LanguageLocaleKey='en_US',
            TimeZoneSidKey='Australia/Sydney',
            Email=c.Email,
            UserName=c.Email,
            Alias=c.Email.subString(0, 8),
            FirstName=c.FirstName,
            LastName=c.LastName
        );
        
        u.setOptions(TriggerEmailOpts());
        
        try {
            insert u;
            
            List<String> permSets = new List<String>();
            
            /*if (!String.isBlank(c.Member_Status__c))
                permSets.add(FamilyPermisionSet);
            
            if (!String.isBlank(c.Training_Status__c))
                permSets.add(VolunteerPermisionSet);

            insert PortalAccessAssignments(u.Id, permSets);*/
        } catch (System.DmlException dEx) {
            if (AccountOwnerWhoHasRole != null && AccountOwnerWhoHasRole.Id != null && dEx.getMessage() == 'Insert failed. First exception on row 0; first error: UNKNOWN_EXCEPTION, portal account owner must have a role: []') {
                try {
                    Account a = [SELECT Id, OwnerId FROM Account WHERE Id =: c.AccountId];
                    a.OwnerId = AccountOwnerWhoHasRole.Id;
                    
                    upsert a;
                    
                    insert u;
                } catch (Exception e) {
                    throw e;
                }
            }
        } catch (Exception e) {
            throw e;
        }   

        return u;   
    }

    private static final String FamilyPermissionSet = 'Family_Portal_Permissions';
    private static final String VolunteerPermissionSet = 'Volunteer_Portal_Permissions';
    private static final String CorporateVolunteerPermissionSet = 'Corporate_Volunteer_Portal_Permissions';
    private static List<PermissionSetAssignment> PortalAccessAssignments(Id userId, List<String> permSets) {
        List<PermissionSet> perms = new List<PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN :permSets]);

        List<PermissionSetAssignment> assigns = new List<PermissionSetAssignment>();

        for (PermissionSet ps : perms)
            assigns.add(new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=userId));

        return assigns;
    }

    private static List<PermissionSetAssignment> RemovePortalAccessAssignments(Id userId, Set<String> permSets) {
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>([SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId AND (PermissionSet.Name = :VolunteerPermissionSet OR PermissionSet.Name = :FamilyPermissionSet)]);
        List<PermissionSetAssignment> delPsas = new List<PermissionSetAssignment>();

        for(PermissionSetAssignment psa : psas) {
            if(!permSets.contains(psa.PermissionSet.Name))
                delPsas.add(psa);
        }

        System.debug('permSets: ' + permSets);
        System.debug('psas: ' + psas);
        System.debug('delPsas: ' + delPsas);

        return delPsas;
    }
    
    private static List<String> ValidateContact(Contact c) {
        List<String> errors = new List<String>();
        
        if (c.FirstName == null || String.isEmpty(c.FirstName))
            errors.add('Missing FirstName');
        if (c.LastName == null || String.isEmpty(c.LastName))
            errors.add('Missing LastName');
        if (c.Email == null || String.isEmpty(c.Email))
            errors.add('Missing Email');
        if (c.AccountId == null || String.isEmpty(c.AccountId))
            errors.add('Missing Organisation');
            
        return errors;
    }
    
    private static Database.DMLOptions TriggerEmailOpts() {
        Database.DMLOptions opts = new Database.DMLOptions();
        opts.EmailHeader.triggerUserEmail = true;
        
        return opts;
    }
}