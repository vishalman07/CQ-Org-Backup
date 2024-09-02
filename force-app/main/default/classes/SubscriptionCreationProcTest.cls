/*
 @Author	:	 Minal Zaa, Camp Quality
 @Desc		:	 Test Class For FieldCustomValidationExceptionTest
				 In the older version ,testMethod can be written in same class.
				 With version update , testMethod has to be written in Test Class
 */

 @isTest(SeeAllData=false)
public with sharing class SubscriptionCreationProcTest {
    public SubscriptionCreationProcTest() {

    }

    private static testmethod void method1(){
        //fake();
        try {
            new SubscriptionCreationProc().process(new Map<String, Object>{
                'id' => 'a',
                'externalId' => 'asd'
            });
        } catch (Exception e) {

        }
    }
}