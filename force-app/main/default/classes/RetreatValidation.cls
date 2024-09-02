public class RetreatValidation {

    public static void checkForExistingPeriod(List<Peak_Period__c> triggerNew) {
        Set<Id> propertyIds = new Set<Id>();
        Set<Date> startDates = new Set<Date>();
        Set<Date> endDates = new Set<Date>();

        for (Peak_Period__c period : triggerNew) {
            propertyIds.add(period.Property__c);
            startDates.add(period.Start_Date__c);
            endDates.add(period.End_Date__c);
        }

        List<Peak_Period__c> existingPeriods = new List<Peak_Period__c>([
                SELECT Id, Start_Date__c, End_Date__c, Property__c
                FROM Peak_Period__c
                WHERE Property__c = :propertyIds
                AND ((Start_Date__c >= :startDates AND Start_Date__c <= :endDates)
                OR (End_Date__c >= :startDates AND End_Date__c <= :endDates)
                OR (Start_Date__c <= :startDates AND End_Date__c >= :endDates))
        ]);

        for (Peak_Period__c period : triggerNew) {
            for (Peak_Period__c existing : existingPeriods) {
                if (period.Property__c.equals(existing.Property__c) && ((Trigger.isUpdate && !(period.Id.equals(existing.Id))) || Trigger.isInsert)) {
                    if (foundOverlap(existing.Start_Date__c, existing.End_Date__c, period.Start_Date__c, period.End_Date__c)) {
                        period.addError('Found existing period, Id: ' + existing.Id);
                    }
                }
            }
        }
    }

    public static void checkForExistingBooking(List<Retreat_Booking__c> triggerNew) {
        Set<Id> propertyIds = new Set<Id>();
        Set<Date> checkInDates = new Set<Date>();
        Set<Date> checkOutDates = new Set<Date>();
        
        for (Retreat_Booking__c booking : triggerNew) {
            if (booking.Check_In_Date__c != null && booking.Check_Out_Date__c != null) {
                propertyIds.add(booking.Property__c);
                checkInDates.add(booking.Check_In_Date__c);
                checkOutDates.add(booking.Check_Out_Date__c);
            }
        }

        System.debug('checkInDates-->'+ checkInDates);
        System.debug('checkOutDates-->'+ checkOutDates);
		
        if (!checkInDates.isEmpty() && !checkOutDates.isEmpty()) {
            List<Retreat_Booking__c> existingBookings = new List<Retreat_Booking__c>([
                    SELECT Id, Check_In_Date__c, Check_Out_Date__c, Property__c, Status__c
                    FROM Retreat_Booking__c
                    WHERE Property__c = :propertyIds
                    AND ((Status__c != 'Cancelled')
                    AND((Check_In_Date__c >= :checkInDates AND Check_In_Date__c <= :checkOutDates)
                    OR (Check_Out_Date__c >= :checkInDates AND Check_Out_Date__c <= :checkOutDates)
                    OR (Check_In_Date__c <= :checkInDates AND Check_Out_Date__c >= :checkOutDates)))
            ]);
    
            for (Retreat_Booking__c booking : triggerNew) {
                if (booking.Check_In_Date__c != null && booking.Check_Out_Date__c != null) {
                    for (Retreat_Booking__c existing : existingBookings) {
                        if (booking.Property__c.equals(existing.Property__c) && ((Trigger.isUpdate && !(booking.Id.equals(existing.Id))) || Trigger.isInsert)) {
                            if (foundOverlap(existing.Check_In_Date__c, existing.Check_Out_Date__c, booking.Check_In_Date__c, booking.Check_Out_Date__c)) {
                                booking.addError('Found existing booking, Id: ' + existing.Id);
                            }
                        }
                    }
                }
            }
        }
    }

    public static Boolean foundOverlap(Date startDate, Date endDate, Date searchStartDate, Date searchEndDate) {
        if ((startDate >= searchStartDate && startDate <= searchEndDate) ||
                (endDate >= searchStartDate && endDate <= searchEndDate) ||
                (startDate <= searchStartDate && endDate >= searchEndDate)) {
            return true;
        }
        return false;
    }
}