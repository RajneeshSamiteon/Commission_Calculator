public class MonthlyBreakdownSelector {
    public static List<monthly_breakdown__c> getMonthlyBreakDownByMonthlyCommission(set<id> monthlyCommissions){
        return [SELECT Id, Name, Account__c, Opportunity__c, Tile_Margin_Percentage__c, 
                                                  Ancillary_Margin_Percentage__c, Commission_Split_Percentage__c, Total_Invoice_Tile_Margin__c, 
                                                  Total_Invoice_Ancillary_Margin__c, Total_Margin__c, Met_Margin__c, Elgible_Amount__c, 
                                                  Monthly_Commission__c ,tile_sale__c, ancillary_sale__c,Monthly_Commission__r.Name,
                                                  Monthly_Commission__r.Employee__c FROM Monthly_Breakdown__c 
                                                  where Monthly_Commission__c in : monthlyCommissions];
        
    }
}