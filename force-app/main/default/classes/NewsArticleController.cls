public class NewsArticleController {

    public String pType {
        get;
        set {
            pType = value;
            
            if(String.isNotEmpty(pType)) {
                load();
            }
        }
    }
    
    public List<Article__c> articles{get;set;}
    
    public NewsArticleController() {
    	load();
    }
    
    public void load() {
        
        articles = [SELECT Id, Name, Title__c, Body_Text__c, Article_Date__c, Close_Date__c, Show_in_Portal__c, Image_URL__c, Article_Link_URL__c
                    FROM Article__c WHERE (Show_in_Portal__c = 'Both' OR Show_in_Portal__c = :pType) AND (Close_Date__c = NULL OR Close_Date__c >= :Datetime.Now())
                   	ORDER BY Order__c ASC NULLS LAST,Article_Date__c DESC];
        
    }
    
}