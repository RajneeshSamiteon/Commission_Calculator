public class CommissionMasterSelector {
    Public Static String getCommissionMasterRecordTypeBases(String recordTypeId){
          return [Select Id,Name from Commission_Master__c where recordTypeId = :recordTypeId Order by createdDate DESC limit 1].Id;
    }
}