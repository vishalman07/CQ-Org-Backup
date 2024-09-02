/* 
 * 
 * @date          April 2023
 * @author        Minal Zaa
 * @description   Test class for LookupSearchResult
 */
@IsTest
public class LookupSearchResultTest {
    
    @IsTest
    static void testLookupSearchResultGetters() {
        // create a LookupSearchResult instance
        Id id = '001000000000000000';
        String sObjectType = 'Account';
        String icon = 'standard:account';
        String title = 'Acme Inc.';
        String subtitle = 'San Francisco';
        LookupSearchResult result = new LookupSearchResult(id, sObjectType, icon, title, subtitle);
        
        // assert that the getters return the expected values
        System.assertEquals(id, result.getId());
        System.assertEquals(sObjectType, result.getSObjectType());
        System.assertEquals(icon, result.getIcon());
        System.assertEquals(title, result.getTitle());
        System.assertEquals(subtitle, result.getSubtitle());
    }
}