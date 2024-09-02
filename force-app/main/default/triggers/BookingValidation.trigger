trigger BookingValidation on Retreat_Booking__c (before insert, before update) {
	//Disabled on 07/12/2023 - Deemed no longer necessary. Daniel R.
    //RetreatValidation.checkForExistingBooking(Trigger.new);
}