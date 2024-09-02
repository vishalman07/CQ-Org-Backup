@IsTest
public class ContactAlertsControllerTest {

    @testSetup
    static void createTestRecords() {
        // Create a user for testing
        User uContext = TestClassUtil.createStdPortalTestUser();  
    }
    

    static testMethod void testLoadPage() {
        User u = [SELECT Id,ContactId FROM User WHERE alias = 'test123' ];

        // Create a test task for the contact
        Task t = new Task(Subject = 'Test Alert', Status = 'Open', WhoId = u.ContactId, 
                            Description = 'Test alert description', ActivityDate = Date.today());
        insert t;

        // Set the current user to be the owner of the contact
        System.runAs(u) {
            // Instantiate the controller and call loadPage method
            ContactAlertsController controller = new ContactAlertsController();
            controller.loadPage();
 
            System.assertNotEquals(null, controller.alerts);
            System.assertEquals(0, controller.alerts.size());
            
        }
    }
}