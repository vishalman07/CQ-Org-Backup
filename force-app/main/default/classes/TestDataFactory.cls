/* 
 * 
 * @date          March 2023
 * @author        Minal Zaa 
 * @description   Reusable method to generate Test Data
 */

 public class TestDataFactory {

    @Testvisible
    private static Integer maxAllowed = 70000;

    public static List<SObject> createTestData(String objectName, Integer numberOfRecords) {
        List<SObject> recordsToInsert = new List<SObject>();

        for (Integer i = 0; i < numberOfRecords; i++) {
            SObject record = generateTestRecord(objectName);
            recordsToInsert.add(record);
        }

        return recordsToInsert;
    }

    private static SObject generateTestRecord(String objectName) {
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) {
            throw new TestDataFactoryException('Object not found: ' + objectName);
        }
        SObject record = objType.newSObject();

        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isCreateable() && !fieldDescribe.isCalculated()) {
                Object ret = generateFieldValue(fieldDescribe) ; 
                if(ret != null){
                    record.put(fieldName, ret);
                }
            }
        }

        return record;
    }

    private static Object generateFieldValue(Schema.DescribeFieldResult fieldDescribe) {
        Schema.DisplayType fieldType = fieldDescribe.getType();
        String fieldName = fieldDescribe.getName();

        if (fieldType == Schema.DisplayType.String) {
            Integer maxLength = fieldDescribe.getLength();
            String testString = 'Test ' + fieldDescribe.getName();
            return testString.length() > maxLength ? testString.substring(0, maxLength) : testString;
       
        } else if (fieldType == Schema.DisplayType.Integer) {

            Integer precision = fieldDescribe.getPrecision();
            Decimal maxValue = Math.min(Math.pow(10, precision) - 1, maxAllowed);
            return (Integer)Math.floor(Math.random() * (maxValue + 1));
 
        } else if (fieldType == Schema.DisplayType.Double) {
            if (fieldName.equalsIgnoreCase('BillingLatitude') || fieldName.equalsIgnoreCase('ShippingLatitude') || 
                fieldName.equalsIgnoreCase('OtherLatitude') || fieldName.equalsIgnoreCase('MailingLatitude')) {
                return (Math.random() * 180.0) - 90.0; // Generate a random latitude value between -90 and 90
            } else if (fieldName.equalsIgnoreCase('BillingLongitude') || fieldName.equalsIgnoreCase('ShippingLongitude') || 
                fieldName.equalsIgnoreCase('OtherLongitude') || fieldName.equalsIgnoreCase('MailingLongitude')) {
                return (Math.random() * 360.0) - 180.0; // Generate a random longitude value between -180 and 180
            } else { 
                Integer precision = fieldDescribe.getPrecision();
                Integer scale = fieldDescribe.getScale();
                Decimal maxValue = Math.min(Math.pow(10, precision - scale) - 1, maxAllowed); 
                return maxValue; 
            } 
        } else if (fieldType == Schema.DisplayType.Date) {
            return Date.today();
        } else if (fieldType == Schema.DisplayType.DateTime) {
            return DateTime.now();
        } else if (fieldType == Schema.DisplayType.Boolean) {
            return true;
        }
        // Add more field types as needed

        return null;
    }

    public class TestDataFactoryException extends Exception {}
}