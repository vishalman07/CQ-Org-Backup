/* 
 * 
 * @date          April 2023
 * @author        Minal Zaa
 * @description   Test class for UserLookupController
 */
@IsTest
public class UserLookupControllerTest {
    
    @IsTest
    static void testSearchWithUserIds() {
        // create 2 users
        
        // create test data
        User testUser1 = TestClassUtil.createStdTestUser();
        User testUser2 = TestClassUtil.createStdTestUser(); 
        
        List<String> userIdList = new List<String>{testUser1.Id, testUser2.Id};
        
        // call search method with user IDs
        List<LookupSearchResult> results = UserLookupController.search('Testing', userIdList);
        
        // assert that results does not contain the expected users
        System.assertEquals(0, results.size()); 
    }
    
    @IsTest
    static void testSearchWithoutUserIds() {
        // call search method without user IDs
        List<LookupSearchResult> results = UserLookupController.search('Testing', null);
        
        // assert that results does not contain the expected users
        System.assertEquals(0, results.size()); 
    }
}