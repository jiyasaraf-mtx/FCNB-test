/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public class LPI_UserRecordJobQueue implements Queueable  {
    private String jobType = '';
	private List<PermissionSetAssignment> permissionSetList;
    private Map<Id, Set<Id>> accRelatedObjAccessToChildAccSetMap;
    private Set<Id> childAccountId;
    private Map<Id,Id> accountIdToUserIdMap;
    private Boolean isRunningTest = Test.isRunningTest();
    
    public LPI_UserRecordJobQueue(
        List<PermissionSetAssignment> permissionSetList,
        Map<Id,Set<Id>> accRelatedObjAccessToChildAccSetMap,
        Set<Id> childAccountId,
        Map<Id,Id> accountIdToUserIdMap,
        String process
    ){
        this.permissionSetList = permissionSetList;
        this.accRelatedObjAccessToChildAccSetMap = accRelatedObjAccessToChildAccSetMap;
        this.childAccountId = childAccountId;
        this.accountIdToUserIdMap = accountIdToUserIdMap;
        if(process == 'create'){
            this.jobType = 'createPermissionSetAssignment';
        }else if(process == 'remove'){
            this.jobType = 'deletePermissionSetAssignment';
        }
    }
    
    public LPI_UserRecordJobQueue(Map<Id,Set<Id>> accRelatedObjAccessToChildAccSetMap, Set<Id> childAccountId, String jobType){
        this.accRelatedObjAccessToChildAccSetMap = accRelatedObjAccessToChildAccSetMap;
        this.childAccountId = childAccountId;
        this.jobType = jobType;
    }
    
    public void execute(QueueableContext context) {
        if(this.jobType == 'createPermissionSetAssignment'){
            if(!this.permissionSetList.isEmpty()){
                INSERT this.permissionSetList;
            }
            this.jobType = 'createSharingRecord';
            if(!this.isRunningTest){
                System.enqueueJob(this);
            }
        }else if(this.jobType == 'deletePermissionSetAssignment'){
            if(!this.permissionSetList.isEmpty()){
                DELETE this.permissionSetList;
            }
            this.jobType = 'deleteSharingRecord';
            if(!this.isRunningTest){
                System.enqueueJob(this);
            }
        }else if(this.jobType == 'createSharingRecord'){
            if(!this.accRelatedObjAccessToChildAccSetMap.isEmpty()){
                LPI_ApexSharingUtility.giveAccessOfObjectsFromAccountIdFromBR(accRelatedObjAccessToChildAccSetMap,childAccountId);
            }
            if(this.accountIdToUserIdMap != null && this.accountIdToUserIdMap.isEmpty()){
                LPI_ApexSharingUtility.giveLocationAccountToPersonAccount(accountIdToUserIdMap);
            }
        }else if(this.jobType == 'deleteSharingRecord'){
            if(!this.accRelatedObjAccessToChildAccSetMap.isEmpty()){                
                LPI_ApexSharingUtility.removeAccessOfObjectsFromAccountIdFromBR(accRelatedObjAccessToChildAccSetMap,childAccountId);
            }
        }   
    }
}