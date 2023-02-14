trigger CommissionTierTrigger on Commission_Tier__c (after insert) {
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            CommissionTierTriggerHandler.CommissionTierTriggerHelper(trigger.newMap);
        }
    }
}