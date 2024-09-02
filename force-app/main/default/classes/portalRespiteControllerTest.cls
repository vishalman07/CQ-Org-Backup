@IsTest
private class portalRespiteControllerTest {
    @IsTest
    static void testPortalRespiteController() {

        User u = [select Id,AccountId from User WHERE CommunityNickname='portaluser'];

        system.runAs(u) {

            Test.startTest();

            Test.setCurrentPage(Page.portalRespite);

            portalRespiteController prc = new portalRespiteController();

            Test.stopTest();

        }


    }

    @IsTest
    static void testPortalRetreatBookingPeak() {

        User u = [select Id,AccountId,ContactId from User WHERE CommunityNickname='portaluser'];

        Account a1 = new Account(Name='t1');
        insert a1;

        Contact c1 = new Contact(FirstName='extra', LastName='guest', Email='text@user.org',AccountId = a1.Id);
        insert c1;

        system.runAs(u) {

            Test.startTest();

            Property__c pPeak = new Property__c( Name = 'pPeak',Address__c = 'test Address',Available_for_booking_portal__c = true,
                    Can_extend_to_full_week_an_own_expense__c = false,Guests__c = 5,Length_of_stay__c='5 days (4 nights)',
                    Peak_period_restrictions__c = true,Portal_Description__c = 'test Desc',State__c = 'VIC',
                    Type__c = 'General',Not_available_on_weekend__c = false);

            insert pPeak;

            Peak_Period__c pp = new Peak_Period__c(Name='Holiday', Start_Date__c = System.today() + 20 ,
                                End_Date__c =System.today()+40,Length_of_stay__c='3 days (2 nights)',Property__c = pPeak.Id);

            insert pp;


            Retreat_Booking__c rb2 = new Retreat_Booking__c( Status__c = 'Waitlisted',Check_In_Date__c = System.today() +10,
                    Check_Out_Date__c = System.today()+15,Property__c = pPeak.Id,Contact__c = u.ContactId);



            Test.setCurrentPage(Page.portalRetreatBooking);

            ApexPages.currentPage().getParameters().put('pid', pPeak.Id);

            //portalRetreatBookingController prbc = new portalRetreatBookingController();

            //String los2 = portalRetreatBookingController.lengthOfStay(pPeak.Id,'01/03/2019');

            Test.stopTest();

        }


    }

    @IsTest
    static void testPortalRetreatBookingSalamander() {

        User u = [select Id,AccountId,ContactId from User WHERE CommunityNickname='portaluser'];

        Account a1 = new Account(Name='t1');
        insert a1;

        Contact c1 = new Contact(AccountId=a1.Id, FirstName='extra', LastName='guest', Email='text@user.org');
        insert c1;

        system.runAs(u) {

            Test.startTest();

            Property__c pSalamander = new Property__c( Name = 'pSalamander',Address__c = 'test Address',Available_for_booking_portal__c = true,
                    Can_extend_to_full_week_an_own_expense__c = false,Guests__c = 5,Length_of_stay__c='5 days (4 nights)',
                    Peak_period_restrictions__c = false,Portal_Description__c = 'test Desc',State__c = 'VIC',
                    Type__c = 'Salamander',Not_available_on_weekend__c = false);

            insert pSalamander;


            Retreat_Booking__c rb = new Retreat_Booking__c( Status__c = 'Waitlisted Q1',Check_In_Date__c = System.today() - 5,
                    Check_Out_Date__c = System.today(),Property__c = pSalamander.Id,Contact__c = u.ContactId);

            insert rb;


            Test.setCurrentPage(Page.portalRetreatBooking);

            ApexPages.currentPage().getParameters().put('pid', pSalamander.Id);

            portalRetreatBookingController prbc = new portalRetreatBookingController();

            String los = portalRetreatBookingController.lengthOfStay(pSalamander.Id,'08/02/2019');

            List<Map<String, String>> rb1 =  portalRetreatBookingController.searchExistingBookings(pSalamander.Id);

            prbc.getFamily();



            Set<Id> s = new Set<Id>();
            s.add(u.ContactId);

            List<Contact> e = new List<Contact>();
            e.add(c1);

            portalRetreatBookingController.bookingWrapper bookWrap = new portalRetreatBookingController.bookingWrapper();
            bookWrap.booking = rb;
            bookWrap.guestRegister = true;
            bookWrap.familyGuest = s;
            bookWrap.extraGuest = e;

            prbc.bw = bookWrap ;

   //         prbc.removeGuestId = 1;

            prbc.countFamilychecked();
            prbc.addExtraGuest();
  //          prbc.removeExtraGuest();
            prbc.countGuestList();

            PageReference pr = prbc.save();


            Test.stopTest();

        }


    }

    @IsTest
    static void testPortalRetreatBookingWeekend() {

        User u = [select Id,AccountId,ContactId from User WHERE CommunityNickname='portaluser'];

        Account a1 = new Account(Name='t1');
        insert a1;

        Contact c1 = new Contact(FirstName='extra', LastName='guest', Email='text@user.org',AccountId = a1.Id);
        insert c1;

        system.runAs(u) {

            Test.startTest();

            Property__c pWeekend = new Property__c( Name = 'pWeekend',Address__c = 'test Address',Available_for_booking_portal__c = true,
                    Can_extend_to_full_week_an_own_expense__c = false,Guests__c = 5,Length_of_stay__c='5 days (4 nights)',
                    Peak_period_restrictions__c = false,Portal_Description__c = 'test Desc',State__c = 'VIC',
                    Type__c = 'General',Not_available_on_weekend__c = true);

            insert pWeekend;

            Retreat_Booking__c rb = new Retreat_Booking__c( Status__c = 'Waitlisted Q1',Check_In_Date__c = System.today() - 5,
                    Check_Out_Date__c = System.today(),Property__c = pWeekend.Id,Contact__c = u.ContactId);

            insert rb;

//Updated all Status__C = Pending to Status__C= Waitlisted. Megan D 1/12/2023

            Test.setCurrentPage(Page.portalRetreatBooking);

            ApexPages.currentPage().getParameters().put('pid', pWeekend.Id);

            portalRetreatBookingController prbc = new portalRetreatBookingController();

            String los1 = portalRetreatBookingController.lengthOfStay(pWeekend.Id,'11/02/2019');

            Test.stopTest();

        }


    }

    @IsTest
    static void retreatValidationTest() {

        User u = [select Id,AccountId,ContactId from User WHERE CommunityNickname='portaluser'];

        Account a1 = new Account(Name='t1');
        insert a1;

        Contact c1 = new Contact(FirstName='extra', LastName='guest', Email='text@user.org',AccountId = a1.Id);
        insert c1;

        system.runAs(u) {

            Test.startTest();

            Property__c pPeak = new Property__c( Name = 'pPeak',Address__c = 'test Address',Available_for_booking_portal__c = true,
                    Can_extend_to_full_week_an_own_expense__c = false,Guests__c = 5,Length_of_stay__c='5 days (4 nights)',
                    Peak_period_restrictions__c = true,Portal_Description__c = 'test Desc',State__c = 'VIC',
                    Type__c = 'General',Not_available_on_weekend__c = false);

            insert pPeak;

            Peak_Period__c pp = new Peak_Period__c(Name='Holiday', Start_Date__c = System.today() + 20 ,
                    End_Date__c =System.today()+40,Length_of_stay__c='3 days (2 nights)',Property__c = pPeak.Id);

            insert pp;

            Peak_Period__c pp1 = new Peak_Period__c(Name='Holiday1', Start_Date__c = System.today() + 30 ,
                    End_Date__c =System.today()+40,Length_of_stay__c='3 days (2 nights)',Property__c = pPeak.Id);

            try{
                insert pp1;
            }catch (Exception e){
                System.debug('Insertion failed');
            }



            Test.stopTest();

        }


    }

    private static User createPortalUser() {

        Account a = new Account(Name='Portal User Account');
        insert a;

        Contact c = new Contact(FirstName='Portal', LastName='User', Email='portal@user.org', AccountId=a.Id,npsp__Deceased__c = false,Exclude_From_Portal__c = false);
        insert c;

        User u = new User(ContactId=c.Id, FirstName=c.FirstName, LastName=c.LastName, ProfileId=CommunityMemberProfile.Id, UserName=c.Email, Email=c.Email, TimeZoneSidKey='Australia/Sydney', Alias='puser', CommunityNickname='portaluser', LocaleSidKey='en_AU', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert u;



        u.Contact = c;
        u.Contact.Account = a;

        return u;
    }

    private static Profile CommunityMemberProfile {
        get {
            if (CommunityMemberProfile == null) {
                try {
                    CommunityMemberProfile = [SELECT Id FROM Profile WHERE Name = 'My Camp Quality Members' LIMIT 1];
                } catch (Exception e) {
                    throw e;
                }
            }

            return CommunityMemberProfile;
        }
        set;
    }

    @testSetup static void SetupTests() {
        portalRespiteControllerTest.createPortalUser();
    }

}