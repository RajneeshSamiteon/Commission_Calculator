public class CommissionTierSelector {
    public static list<Commission_Tier__c> getRetroactiveTiersByCommissionMaster(set<id> commissionMasterIds,string CommissionType){
        return [SELECt id, commission_master__c ,minimal_retroactive__c,lower_Amount__c , profile_type__c from Commission_Tier__c where tier_type__c=: CommissionType and commission_master__c IN: commissionMasterIds ORDER BY lower_Amount__c ASC];
    }
}