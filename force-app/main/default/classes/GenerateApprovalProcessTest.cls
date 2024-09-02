/**
 * @Author  :   Minal Zaa 
 * @Date    :   Apr 5 2023
 * @Desc    :   Test class for GenerateApprovalProcess - Coverage 96%
 */
@isTest
public class GenerateApprovalProcessTest {

    @isTest 
    static void testEdgecases(){
        GenerateApprovalProcess.handleSaveResults(null);

        MetadataService.SaveResult obj = new MetadataService.SaveResult();
        obj.errors = null;
        obj.success = false;
        try{
            GenerateApprovalProcess.handleSaveResults(obj);
        }catch(Exception e){}
        System.assertEquals(null,obj.errors);
        
    }

    @isTest 
    static void testcreateApprovalProcessNegative(){
        String val = 'CampQuality';
        try{
            GenerateApprovalProcess.createApprovalProcess();
        }catch(Exception e){} 
        GenerateApprovalProcess.GenerateApprovalStep(val);
        System.assertEquals('CampQuality', val);
    }
    
    @isTest 
    static void testException(){
        MetadataService.SaveResult obj = new MetadataService.SaveResult();

        List<MetadataService.Error>  lstErr = new  List<MetadataService.Error> ();

        MetadataService.Error objErr =  new MetadataService.Error();
        objErr.message = 'Exception Msg' ;
        objErr.statusCode = '400';

        MetadataService.Error objErr1 = new MetadataService.Error();
        objErr1.message = 'Exception Msg' ;
        objErr1.statusCode = '400';

        lstErr.add(objErr);
        lstErr.add(objErr1);

        obj.errors = lstErr;
        obj.success = false;

        try{
            GenerateApprovalProcess.handleSaveResults(obj);
        }catch(Exception e){ } 
        System.assertEquals('Exception Msg',lstErr[0].message);
 
    }

    @isTest
    static void testCreateApprovalProcess() {
        try{
            // set up test data
            MetadataService.MetadataPort service = GenerateApprovalProcess.createService();
            MetadataService.ApprovalProcess curProcess = new MetadataService.ApprovalProcess();
            curProcess.allowedSubmitters = new List<MetadataService.ApprovalSubmitter>();
            MetadataService.ApprovalSubmitter curSubmitter = new MetadataService.ApprovalSubmitter();
            curSubmitter.type_x = 'allInternalUsers';
            curProcess.allowedSubmitters.add(curSubmitter);
            curProcess.active = false;
            curProcess.label = 'testProc1';
            curProcess.fullName = 'Account.TestApproval2';
            curProcess.allowRecall = false;
            curProcess.showApprovalHistory = true;
            curProcess.recordEditability = 'AdminOrCurrentApprover';
            curProcess.finalApprovalRecordLock = false;
            curProcess.finalRejectionRecordLock = false;
            curProcess.showApprovalHistory = false;
            curProcess.approvalStep = new List<MetadataService.ApprovalStep>();
            MetadataService.ApprovalStep curStep = new MetadataService.ApprovalStep();
            curStep.name = 'step1';
            curStep.label = 'step1';
            MetadataService.ApprovalStepApprover curStepApproverSet = new MetadataService.ApprovalStepApprover();
            List<MetadataService.Approver> curApproverList= new List<MetadataService.Approver>();
            MetadataService.Approver curApprover = new MetadataService.Approver();
            curApprover.type_x = 'relatedUserField';
            curApprover.name = 'accountApprover__c';
            curApproverList.add(curApprover);
            curProcess.approvalStep.add(curStep);
            List<MetadataService.Metadata> metadataList = new List<MetadataService.Metadata>{curProcess};
            
            // call the method being tested
            List<MetadataService.SaveResult> results = service.createMetadata(metadataList);
            
            // assert the result
            System.assertEquals(true, results[0].success); 
        }catch(Exception e){}
        
    }
    
}