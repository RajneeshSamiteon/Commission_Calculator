public class MonthlyCommissionSelector {
    public static List<Monthly_Commission__c> getMonthlyCommissionByEmployee(){
        return [Select Id,Name,Employee__c,EoY_Sales_Commission__c,Ancillary_Margin__c,Ancillary_Margin_Percent__c,Cost__c,Date__c,Eligible_Margin__c,
                Margin__c,Month__c,Not_Elligible_Margin__c,Price__c,Target_Met__c,Tile_Margin__c,Tile_Margin_Percent__c from Monthly_Commission__c
                where createdDate = LAST_YEAR];                                 	
    }
    public static List<Monthly_Commission__c> getMonthlyCommissionByEmployeeAndBreakDown(set<id> monthlyCommissionIds){
        return [Select Id,Name,Employee__c,EoY_Sales_Commission__c,Ancillary_Margin__c,Ancillary_Margin_Percent__c,Cost__c,Date__c,Eligible_Margin__c,
                Margin__c,Month__c,Not_Elligible_Margin__c,Price__c,Target_Met__c,Tile_Margin__c,Tile_Margin_Percent__c from Monthly_Commission__c
                where createdDate = THIS_YEAR AND Id in: monthlyCommissionIds];                                 	
    }
}