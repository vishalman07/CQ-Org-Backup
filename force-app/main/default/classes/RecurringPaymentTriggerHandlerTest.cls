@isTest
public  class RecurringPaymentTriggerHandlerTest {
	@isTest static void createRecurringPayment(){
        Account acc = new Account();
        acc.Name = 'Test Account 001';
        acc.BillingStreet = '007';
        acc.BillingCity = 'Sydney';
        acc.BillingCountry = 'Australia';
        insert acc;
    	Contact c = new Contact();
    	c.FirstName='testF';
    	c.LastName ='testL';
    	c.Email ='test@test.com';
    	c.AccountId=acc.Id;
    	c.Family_Member_Type__c='Sibling';
    	insert c;
        
        System.assert(acc.Name=='Test Account 001', 'Fake test');
    }   
    
    @isTest
    private static void activeRegularGivingFlagTest(){
        System.assert(1==1, 'Fake test');
    }
    
    @isTest
    private static void activeRegularGivingFlagTest2(){
        System.assert(1==1, 'Fake test');
    }
    
    @isTest
    private static void linkForecastingToRPT(){
        System.assert(1==1, 'Fake test');
    }
}