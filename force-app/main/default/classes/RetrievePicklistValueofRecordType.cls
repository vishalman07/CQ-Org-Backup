public class RetrievePicklistValueofRecordType {
	public String objectName{get;set;}
     public String recordTypeName{get;set;}
     public String fieldName{get;set;}
     public List<String> listofValue{get;set;} 
     public retrievePicklistValueofRecordType() { 
         objectName = ''; 
         recordTypeName = ''; 
         fieldName = ''; 
         listofValue = new List<String>(); 
     }     
     public void retrieveValue(){       
         //listofValue=MetadataServiceExamples.getDependentPicklistValuesByRecordType(objectName,recordTypeName,fieldName);
     }
}