public class MonthlyBreakDownSelector {
   
    public static list<monthly_breakdown__c> getMonthlyBreakDownViaMonthlyCommission(set<id> monthlyCommission){
        
        Map<id ,monthly_breakdown__c> monthlygetMonthlyBreakDownViaMonthlyCommission = new Map<id ,monthly_breakdown__c>([SELECT Id, Name, Account__c, Opportunity__c, Tile_Margin_Percentage__c, Ancillary_Margin_Percentage__c, Commission_Split_Percentage__c, Total_Invoice_Tile_Margin__c, Total_Invoice_Ancillary_Margin__c, Total_Margin__c, Met_Margin__c, Elgible_Amount__c, Monthly_Commission__c ,Monthly_Commission__r.Name FROM Monthly_Breakdown__c where Monthly_Commission__c in : monthlyCommission]);
    }
}