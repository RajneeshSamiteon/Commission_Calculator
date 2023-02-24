public class PercentUnderRetEoYAdjMetaDataSelector {
    public static double getTargetUnderEOYAdjustment(){
        return [Select Id,Commission_Percentage__c from Percentage_Less_then_retroactive_EOY_adj__mdt].Commission_Percentage__c;
    }
}