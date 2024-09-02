public with sharing class BatchCheckForecasting implements Database.Batchable<sObject>, Schedulable {
     public Database.QueryLocator start(Database.BatchableContext bc) {
    	return Database.getQueryLocator('');
    }
    
   public void execute(Database.BatchableContext bc, List<sObject> objs){

   }
   
   public void execute(SchedulableContext sc) {
  

   }
   public void finish(Database.BatchableContext bc){

   }
}