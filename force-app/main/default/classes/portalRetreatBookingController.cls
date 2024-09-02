public class portalRetreatBookingController {

    public Boolean noId { get { return String.isBlank(propertyId);} }
    public String propertyId {get; set;}
    public Property__c property {get; set;}
    public Retreat_Booking__c booking {get; set;}
    public String contactId {get;set;}
    public static Boolean lockBooking {get;set;}{lockBooking = false;}
    public bookingWrapper bw {get;set;}
    public Map<Id,Contact> familyMap{get;set;} {familyMap = new Map<Id,Contact>();}
    public Map<Id,Boolean> familyChecked{get; set;} {familychecked = new Map<Id,Boolean>();}
    public Decimal sizeOfGuest {get;set;}{sizeOfGuest = 0;}
    public Integer removeGuestId {get;set;}
    public String aId {get;set;}


    public portalRetreatBookingController(){
        propertyId = ApexPages.currentPage().getParameters().get('pid');

        contactId = [Select ContactId from User where id =: Userinfo.getUserid() LIMIT 1].ContactId; // get logged in user id
        System.debug('contactId--------------->'+  contactId);
        if(String.isNotBlank(propertyId)){
            property = [
                    SELECT Address__c,Available_for_booking_portal__c,
                            Can_extend_to_full_week_an_own_expense__c,
                            Guests__c,Id,Image_URL__c,Length_of_stay__c,
                            Name,Peak_period_restrictions__c,Portal_Description__c,
                            State__c,Type__c,Not_available_on_weekend__c
                    FROM Property__c
                    WHERE Id =: propertyId];
            
            System.debug('property Id =====> ' + property.Id);

            booking = new Retreat_Booking__c();

            bw = new bookingWrapper();

            bw.booking = booking;


            List<Retreat_Booking__c> ext_bookings = new List<Retreat_Booking__c>([
                    SELECT Id, Status__c, Check_In_Date__c, Check_Out_Date__c
                    FROM Retreat_Booking__c
                    WHERE Property__c =: property.Id
                    AND Check_Out_Date__c >= TODAY
                    AND Status__c LIKE 'Waitlisted%'
                    AND Contact__c = :contactId
            ]);

            if(!ext_bookings.isEmpty()){
                lockBooking = true;
            }

            aId = [SELECT AccountId FROM Contact WHERE Id =: contactId].AccountId;
        }
    }

    @RemoteAction
    public static List<Map<String, String>> searchExistingBookings(String pid) {
       String cId = [Select ContactId from User where id =: Userinfo.getUserid() LIMIT 1].ContactId; // get logged in user id

        List<Map<String,String>> dates = new List<Map<String, String>>();

        List<Retreat_Booking__c> ext_bookings = new List<Retreat_Booking__c>([
                SELECT Id, Status__c, Check_In_Date__c, Check_Out_Date__c
                FROM Retreat_Booking__c
                WHERE Property__c =: pid
                AND Check_Out_Date__c >= TODAY
                AND Status__c != 'Cancelled'
                AND Contact__c = :cId
        ]);

        if(!ext_bookings.isEmpty()){
            for(Retreat_Booking__c rb: ext_bookings){

                if(rb.Status__c == 'Waitlisted Q1'){
                    lockBooking = true;
                }

                dates.add( new Map<String, String> {
                        'start' => String.valueOf(rb.Check_In_Date__c),
                        'end' => String.valueOf(rb.Check_Out_Date__c),
                        'title' => rb.Status__c,
                        'description' => 'Booked from ' + String.valueOf(rb.Check_In_Date__c) + ' till ' + String.valueOf(rb.Check_Out_Date__c)
//                        'rendering' => 'background'
                });

            }
        }
        return dates;
    }

    @RemoteAction
    public static String lengthOfStay(String pid,String startDate){

        System.debug('inside length of stay');
        String los ;

        System.debug('pId-->'+pid);


        System.debug('Start Date-->'+startDate);
        Date sDate = date.parse(startDate);

        System.debug('convert Start Date-->'+sDate);



        List<Property__c> prt = [
                SELECT Address__c,Available_for_booking_portal__c,
                        Can_extend_to_full_week_an_own_expense__c,
                        Guests__c,Id,Image_URL__c,Length_of_stay__c,
                        Name,Peak_period_restrictions__c,Portal_Description__c,
                        State__c,Type__c,Not_available_on_weekend__c
                FROM Property__c
                WHERE Id =: pId LIMIT 1];

        if(prt != null){

            if(prt[0].Type__c == 'Salamander') {
                //Salamander Bay:
                // if they book on sunday they have 6 Days (5 nights)
                // if they book on friday they have 3 Days (2 nights);

               /* DateTime myDateTime = (DateTime) sDate;
                String dayOfWeek = myDateTime.format('E');

                    if(dayOfWeek == 'Fri'){
                        los = '3 Days (2 nights)';
                    }else{
                        los = '6 Days (5 nights)';
                    }
                
                    
                }*/
                los = '6 Days (5 nights)';

            }else if(prt[0].Not_available_on_weekend__c) {
                DateTime myDateTime = (DateTime) sDate;
                String dayOfWeek = myDateTime.format('E');

                if(dayOfWeek == 'Mon'){
                    los = '5 Days (4 nights)';
                }

            }else{
                if(prt[0].Peak_period_restrictions__c){
                    for(Peak_Period__c pe :[SELECT Id,Name,Start_Date__c,End_Date__c,Length_of_stay__c
                            FROM Peak_Period__c
                            WHERE Property__c =: pid]){

                                if(sDate >= pe.Start_Date__c && sDate <= pe.End_Date__c){
                                    los = pe.Length_of_stay__c;
                                }
                            }
                    }
            }
        }

        if(los == null){
                los = prt[0].Length_of_stay__c;
        }

        return los;
    }



    public void getFamily(){


        for(Contact family :[SELECT Id, FirstName, LastName, Family_Member_Type__c, Birthdate, Swimming_Ability__c, Shirt_Size__c
                                FROM Contact
                                WHERE npsp__Deceased__c = false
                                AND Exclude_From_Portal__c = false
                                AND AccountId = :aId]){

            familyMap.put(family.Id,family);
            familyChecked.put(family.Id,false);

                }



        System.debug('inside getFamily');
        System.debug(familyChecked);


    }

    public PageReference save(){




        String ownerID = [SELECT Id FROM Group WHERE DeveloperName = 'Respite_Team' and Type='Queue'].Id ;


        booking = bw.booking;

        System.debug(bw.guestRegister);

       booking.Contact__c = contactId;
        booking.Property__c = propertyId;
        booking.Status__c = 'Waitlisted Q1';
        booking.OwnerId = ownerID;

        System.debug(booking);

        try{
            upsert booking;


        }catch(Exception e){
            System.debug('Retreat Booking Error '+ e.getLineNumber() + e.getMessage() + e.getStackTraceString());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
            ApexPages.addMessage(msg);
        }

        List<Guest_Booking__c> GuestBookings = new List<Guest_Booking__c>();

        if(bw.familyGuest.size() > 0){
            for(String fg : bw.familyGuest){
                Guest_Booking__c temp = new Guest_Booking__c();
                        temp.Property__c = propertyId;
                        temp.Retreat_Booking__c = booking.Id;
                        temp.Contact__c = fg;


                GuestBookings.add(temp);
            }
        }

        List<Contact> GuestConatcts = new List<Contact>();

        if(bw.extraGuest.size() > 0){
            for(Contact eg: bw.extraGuest){
                if(eg.LastName != null){
                //    Contact temp = new Contact();



                    Guest_Booking__c temp = new Guest_Booking__c();
                    temp.Property__c = propertyId;
                    temp.Retreat_Booking__c = booking.Id;
                  //  temp.Contact__c = fg.Id;
                    temp.Guest_First_Name__c = eg.FirstName;
                    temp.Guest_Last_Name__c  = eg.LastName;
                    temp.Guest_Birthdate__c = eg.Birthdate;
                    temp.Guest_Relationship__c = eg.Family_Member_Type__c;

                    GuestBookings.add(temp);
                  //  GuestConatcts.add(temp);
                }
            }


        }

//        if(GuestConatcts.size() > 0) {
//            try {
//                upsert GuestConatcts;
//            } catch (Exception e) {
//                System.debug('Retreat Booking create extra guest contact Error ' + e.getLineNumber() + e.getMessage() + e.getStackTraceString());
//                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
//                ApexPages.addMessage(msg);
//            }
//
//            for(Contact fg : GuestConatcts){
//                Guest_Booking__c temp = new Guest_Booking__c();
//                temp.Property__c = propertyId;
//                temp.Retreat_Booking__c = booking.Id;
//                temp.Contact__c = fg.Id;
//
//
//                GuestBookings.add(temp);
//            }
//        }

        if(GuestBookings.size() > 0){

            try {
                insert GuestBookings;

            } catch (Exception e) {
                System.debug('Retreat Booking create extra guest contact Error ' + e.getLineNumber() + e.getMessage() + e.getStackTraceString());
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
                ApexPages.addMessage(msg);
            }

        }
//Updated Retreat Booking status__c=Pending to status__c=Waitlisted for all values. Updated status__c= Declined to status__c=Cancelled for all values. MDavis 1/12/2023

        System.debug(booking.Id);

        if(booking.Id != null){

            System.debug('create a case');


            String cId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Respite_Case'].Id;

            Case aCase = new Case();

            aCase.RecordTypeId = cId;
            aCase.OwnerId = ownerID;
            aCase.Reason = 'Request a Booking';
            aCase.Subject = property.Name;
            aCase.Property__c = property.Id;
            aCase.AccountId = aId;
            aCase.ContactId = contactId;
            aCase.Status = 'New';
            aCase.Origin = 'Community';
            aCase.Type = 'Request a Booking';


            try{
                insert aCase;
                booking.Id = null;
                lockBooking = true;

                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your Booking request submitted successfully');
                ApexPages.addMessage(msg);

                PageReference pageRef = new PageReference('/members/portalPage?s=familyPortal&p=RetreatBookingConfirmation');
                pageref.setRedirect(true);
                return pageRef;

            }catch (Exception e) {
                System.debug('Retreat Booking create case Error ' + e.getLineNumber() + e.getMessage() + e.getStackTraceString());
            }

        }

        return null;

    }


    public class bookingWrapper{
        public Retreat_Booking__c booking {get; set;}
        public Boolean guestRegister {get;set;}
        public Set<Id> familyGuest {get;set;}{familyGuest = new Set<Id>();}
        public List<Contact> extraGuest {get;set;}{extraGuest = new List<Contact>();}

    }

    public void countFamilychecked() {
        //sizeOfGuest = 0;
        System.debug('inside countFamilychecked');

        System.debug(familyChecked);


        for(String f: familyChecked.keySet()){
            if(familyChecked.get(f)){

                bw.familyGuest.add(f);
            }else{
                if(bw.familyGuest.contains(f)){
                    bw.familyGuest.remove(f);
                }
            }

        }

        countGuestList();

        if(sizeOfGuest > bw.booking.Guests__c){
            bw.extraGuest.remove(bw.extraGuest.size() - 1);
        }
        countGuestList();

    }

    public void addExtraGuest(){

        bw.extraGuest.add(new contact());

        countGuestList();


    }

    public void removeExtraGuest(){

        System.debug('inside remove extra guest');
        Integer i = removeGuestId;
        System.debug(i-1);
        System.debug(bw.extraGuest.get(i-1));

        bw.extraGuest.remove(i-1);

        countGuestList();


    }

    public void countGuestList(){

        sizeOfGuest = bw.familyGuest.size();
        sizeOfGuest += bw.extraGuest.size();



    }

}