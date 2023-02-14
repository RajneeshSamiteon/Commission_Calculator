/*
 * this handler is for separating the marginal and retroactive threshold for every profile.
 * this were genrally update the first retroactive type commission tier record checkbox name minimal retro active__c
*/

public class CommissionTierTriggerHandler {
    public static void CommissionTierTriggerHelper(map<id,Commission_Tier__c> CommissionTiers)
    {
        list<Commission_Tier__c> allCommissionTiers = new list<Commission_Tier__c>(); 
        set<id> commissionMasterIds = new set<id>();
        for(Commission_Tier__c tier : CommissionTiers.values())
        {
            if(tier.commission_master__c != NULL)
            {
                commissionMasterIds.add(tier.commission_master__c);
            }
        }
        string CommissionType  =commissionCalculatorconstants.RectroActive;
        allCommissionTiers =CommissionTierSelector.getRetroactiveTiersByCommissionMaster(commissionMasterIds,CommissionType);
        set<id> repeatingCommissionMasterId = new set<id>();
        for(Commission_Tier__c tier : allCommissionTiers)
        {
            if(repeatingCommissionMasterId.contains(tier.commission_master__c))
            {
                if(tier.minimal_retroactive__c)
                {
                    tier.minimal_retroactive__c = false;
                }
            }
            else
            {
                tier.minimal_retroactive__c = true;
            }
            repeatingCommissionMasterId.add(tier.commission_master__c);
        }
        try {
            update allCommissionTiers;
        } 
        catch(DmlException e) {
            ExceptionUtils.createExceptionLogV2('Commission_Tier__c',e.getMessage(),e.getStackTraceString());
        }
    }
}