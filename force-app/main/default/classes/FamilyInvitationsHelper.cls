/*******************************************************************************************
* @Name         FamilyInvitationsHelper 
* @Author       Amit Yadav <amit6164339@gmail.com>
* @Date         05/19/2023
* @Description  This class is used as a helper for the FamilyInvitationsController
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Amit Yadav      05/19/2023          Initial Creation                                                      
*******************************************************************************************/
public class FamilyInvitationsHelper implements Queueable {
    List<sObject> sObjList;
    String operationType;
    public FamilyInvitationsHelper(List<sObject> recordList, String operationType){
        this.sObjList = new List<sObject>();
        this.operationType = operationType;
        this.sObjList.addAll(recordList);
    }
    
    public void execute(QueueableContext qc) {
        if('Upsert'.equalsIgnoreCase(operationType) && sObjList.size() > 0){
            Upsert sObjList;
        }
    }
}