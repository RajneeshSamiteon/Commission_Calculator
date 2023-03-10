public class EoYSalesCommissionCalculation implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,EoY_Sales_Commission__r.Commission_Master__c,EoY_Sales_Commission__r.Commission_Master__r.recordType.Name,Employee__c,Cumulative_Total_Sale__c,Cumulative_Total_Margin__c,Cumulative_Eligible_Margin__c,Total_Commission__c,Paid_Commission__c from Monthly_Commission__c Where CALENDAR_MONTH(createdDate)=12 AND createdDate=THIS_YEAR';
        return Database.getQueryLocator(query);   
    }
    public void execute(Database.BatchableContext BC, List<Monthly_Commission__c> monthlyCommissions){

        Map<String, EoY_Sales_Commission__c> EOYSalesCommissionByProfile  = new Map<String, EoY_Sales_Commission__c>(); // this is for stroring EOYSales By Profile baises
        Map<String, commission_master__c> commissionMasterByProfile = new Map<String , commission_master__c>(); // this is to store comission master by same profile Basis
        for(commission_master__c commissionMaster : CommissionMasterSelector.getCommissionMasterRecordTypeBases()){

            commissionMasterByProfile.put(commissionMaster.recordType.Name, commissionMaster);
        }
//        commissionMasterByProfile = datafactory.getSobjectByRecordTypeString(CommissionMasterSelector.getCommissionMasterRecordTypeBases() ,'recordType.Name');
        set<id> commissionMasterId = new set<id>();  //  All commission master id for requried data
        for(commission_master__c commissionMaster : commissionMasterByProfile.values()){
            commissionMasterId.add(commissionMaster.id);
        }

        Map<id, List<EoY_GP_Target_Bonus__c>> gPTargetBonus = new Map<id , List<EoY_GP_Target_Bonus__c>>();  //  this is to store EOY GP Target Bonus by commission master ID
        gPTargetBonus = datafactory.getsObjectsByFieldId(EoYGPBonusTargetSelector.getEoYGPBonusTargetByCommissionMasters(commissionMasterId) , 'Commission_Master__c');

        
        Map<String , Map<id,Monthly_Commission__c>> monthlyCommissionByProfileAndEoySales = new Map<String , Map<id , Monthly_Commission__c>>();  // this is to stroe all the monthly commission by profile name and Eoy sales
        Set<id> eoySalesId = new Set<id>();
        for(monthly_commission__c monthlyCommission : monthlyCommissions){

            if(monthlyCommissionByProfileAndEoySales.containsKey(monthlyCommission.EoY_Sales_Commission__r.Commission_Master__r.recordType.Name)){
                if(!monthlyCommissionByProfileAndEoySales.containsKey(monthlyCommission.EoY_Sales_Commission__c)){
                    monthlyCommissionByProfileAndEoySales.get(monthlyCommission.EoY_Sales_Commission__r.Commission_Master__r.recordType.Name).put(monthlyCommission.EoY_Sales_Commission__c,monthlyCommission);
                } 
            }
            else{
                monthlyCommissionByProfileAndEoySales.put(monthlyCommission.EoY_Sales_Commission__r.Commission_Master__r.recordType.Name , new Map<id,monthly_commission__c> {monthlyCommission.EoY_Sales_Commission__c => monthlyCommission});
            }
            eoySalesId.add(monthlyCommission.EoY_Sales_Commission__c);
        }
        // EOY sales Commission By Profile Type
        for(EoY_Sales_Commission__c salesComission : EoYSalesCommissionSelector.GetEoysalesCommissions(eoySalesId).values()){
			EOYSalesCommissionByProfile.put(salesComission.Commission_Master__r.recordtype.name ,salesComission);
        }

        for(String profile : monthlyCommissionByProfileAndEoySales.keyset()){

            if(profile == commissionCalculatorconstants.REPTYPEAD){
                EOYSalesCommissionHandler.eOYSalesRepAnD(monthlyCommissionByProfileAndEoySales.get(profile),EOYSalesCommissionByProfile.get(profile),commissionMasterByProfile.get(profile) , gPTargetBonus );
            }

        }
    }
    public void finish(Database.BatchableContext BC){
        
    }
}