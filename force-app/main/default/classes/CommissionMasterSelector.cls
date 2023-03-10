public class CommissionMasterSelector {
    Public Static Id getCommissionMasterRecordTypeBases(Id recordTypeId){
          return [Select Id,Name from Commission_Master__c where recordTypeId = :recordTypeId Order by createdDate DESC limit 1].Id;
    }
    public static Map<Id,Commission_Master__c> getCommissionMasterById(Set<Id> commissionMasters){
        Map<Id,Commission_Master__c> commissionMasterById = new Map<Id,Commission_Master__c>([SELECT Id, Name, Commission_percent_under_target__c, Target_for_EoY_adjustment__c,
        Percent_below_retroactive_EoY_Adj__c, RecordTypeId FROM Commission_Master__c 
        WHERE Id IN : commissionMasters]);
        return commissionMasterById;
    }
}