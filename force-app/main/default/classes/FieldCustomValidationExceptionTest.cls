/*
 @Author	:	 Minal Zaa, Camp Quality
 @Desc		:	 Test Class For FieldCustomValidationExceptionTest
				 In the older version ,testMethod can be written in same class.
				 With version update , testMethod has to be written in Test Class
 */


@isTest 
public with sharing class FieldCustomValidationExceptionTest {
    public FieldCustomValidationExceptionTest() {

    }

    public static testmethod void testCustomMessage(){
		
		try{
			Account c = new Account();
			insert c;
		}
		catch( DmlException e1 ) {
			try{
				throw new FieldCustomValidationException( e1 );
			}
			catch( FieldCustomValidationException e2 ){
				System.assert( e2.getCustomMessage() != '' );
			}
			
		}
	}
}