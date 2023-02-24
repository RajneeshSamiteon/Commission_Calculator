public class CommissionMasterRecordTypeBases implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        try{
            String commissionMasterRecordtype = 'Select Id,Name from RecordType Where SobjectType=\'Commission_Master__c\'';
            return Database.getQueryLocator(commissionMasterRecordtype);   
        }
        catch(DmlException e) {
            ExceptionUtils.createExceptionLogV2('Commission_Master__c',e.getMessage(),e.getStackTraceString());
            return null;
        }
    }
    public void execute(Database.BatchableContext BC, list<RecordType> commissionMasterRecordtype){
        System.debug('commissionMasterRecordtype ::'+commissionMasterRecordtype);
        double targetEoYAdjustment = TargetForEoYAdjustmentMetadataSelector.getEoYAdjustmentTarget();
        double commissionUnderTarget = CommissionUnderTargerMetadataSelector.getCommissionPercentUnderTarget();
        double targetUnderEoYAdjustment = PercentUnderRetEoYAdjMetaDataSelector.getTargetUnderEOYAdjustment();
        List<Commission_Master__c> listCommissionMaster = new List<Commission_Master__c>();
        for(RecordType recordtype : commissionMasterRecordtype){
            if(recordtype.name==CommissionCalculatorConstants.REPTYPEAD){
                Commission_Master__c commissionMaster = new Commission_Master__c();
                commissionMaster.Name = recordtype.name;
                commissionMaster.Target_for_EoY_adjustment__c = targetEoYAdjustment;
                commissionMaster.Commission_percent_under_target__c = commissionUnderTarget;
                commissionMaster.Percent_below_retroactive_EoY_Adj__c = targetUnderEoYAdjustment;
                listCommissionMaster.add(commissionMaster);
            }
        }
        System.debug('listCommissionMaster ::'+listCommissionMaster);
        insert listCommissionMaster; 
    }
    public void finish(Database.BatchableContext BC){
        
    }
}