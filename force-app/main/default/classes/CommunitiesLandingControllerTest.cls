/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest public with sharing class CommunitiesLandingControllerTest {
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
      }
    @isTest
    static void testForwardToStartPage() {
        // Create a new instance of the controller
        CommunitiesLandingController controller = new CommunitiesLandingController();
        
        // Call the forwardToStartPage method and store the result
        PageReference result = controller.forwardToStartPage();
        
        // Verify that the result is not null
        System.assertNotEquals(null, result);

    }

}