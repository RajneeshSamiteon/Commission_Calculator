public class EOYSalesCommissionHandler {
    public static void eOYSalesRepAnD(Map<Id ,Monthly_commission__c> monthlyCommssionByEoySalesId , EOY_sales_commission__c eoySalesCommission , 
                                      commission_master__c commissionMaster , Map<Id, List<EoY_GP_Target_Bonus__c>> gPTargetBonus) 
    {
        monthly_commission__c monthlyCommission = new monthly_commission__c();
        monthlyCommission = monthlyCommssionByEoySalesId.get(eoySalesCommission.id);
        eoySalesCommission.Eligible_Margin__c = monthlyCommission.Cumulative_Eligible_Margin__c;
        eoySalesCommission.Total_Margin__c = monthlyCommission.Cumulative_Total_Margin__c;
        eoySalesCommission.Non_Eligible_Margin__c = eoySalesCommission.Total_Margin__c - eoySalesCommission.Eligible_Margin__c;
        eoySalesCommission.Total_Sale__c = monthlyCommission.Cumulative_Total_Sale__c;
        eoySalesCommission.Over_All_Margin_percent__c = ((eoySalesCommission.Total_Margin__c/eoySalesCommission.Total_Sale__c)*100).setScale(2);
        
        if(eoySalesCommission.Total_Sale__c >= commissionMaster.Minimum_Retroactive_Threshold__c){
            
            Decimal nonEligibleAmountCommission =0.0;
            nonEligibleAmountCommission =((monthlyCommission.Cumulative_Total_Margin__c-monthlyCommission.cumulative_eligible_margin__c)* commissionMaster.Commission_percent_under_target__c)/100;
            if(eoySalesCommission.Over_All_Margin_percent__c >= commissionMaster.Target_for_EoY_adjustment__c){
                nonEligibleAmountCommission += ((monthlyCommission.Cumulative_Total_Margin__c-monthlyCommission.Cumulative_Total_Margin__c)* commissionMaster.Percent_below_retroactive_EoY_Adj__c)/100;
            }
            else{
                //Dont Hit 35% of margin
            }
            eoySalesCommission.Total_Commission__c = monthlyCommission.total_commission__c + nonEligibleAmountCommission;
        }
        else{
            // not cover mininmum rectroactive threshHold
            if(eoySalesCommission.Over_All_Margin_percent__c >= commissionMaster.Target_for_EoY_adjustment__c){
                Decimal nonEligibleAmountCommission =0.0;
                nonEligibleAmountCommission += ((monthlyCommission.Cumulative_Total_Margin__c-monthlyCommission.Cumulative_Total_Margin__c)* commissionMaster.Percent_below_retroactive_EoY_Adj__c)/100;
                eoySalesCommission.Total_Commission__c = monthlyCommission.total_commission__c + nonEligibleAmountCommission;
            }
        }
    }
}
