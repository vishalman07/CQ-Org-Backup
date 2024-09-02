public class SpecialNeedsListController {
public String cId{
        get;
        set {
            cId = value;
            load();
        }
    }
    
    public List<Special_Needs__C> sneeds{get;set;}
	
    public SpecialNeedsListController() {
        
        load();
        
    }
    
    public void load() {
        if(String.isNotEmpty(cId)) {
            
            sneeds = [select Long_Description__c, Comments__c, Date__c
                      FROM Special_Needs__C where  Contact__c   = :cId];
            
        }
    }
}