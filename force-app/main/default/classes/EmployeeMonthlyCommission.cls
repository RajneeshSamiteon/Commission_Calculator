public class EmployeeMonthlyCommission implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        try{
            String listMonthlyCommission = 'Select Id,Employee__c,Tile_Sale__c,Ancillary_Sale__c,EoY_Sales_Commission__c,Tile_Margin_Percent__c,Tile_Margin__c,Target_Met__c,Price__c,Not_Elligible_Margin__c,Margin__c,Month__c,Ancillary_Margin__c,Ancillary_Margin_Percent__c,Cost__c,Date__c,Eligible_Margin__c from Monthly_Commission__c where createdDate = LAST_Month';
            return Database.getQueryLocator(listMonthlyCommission);   
        }
        catch(DmlException e) {
            ExceptionUtils.createExceptionLogV2('EoY_Sales_Commission__c',e.getMessage(),e.getStackTraceString());
            return null;
        }
    }
    public void execute(Database.BatchableContext BC, list<Monthly_Commission__c> listMonthlyCommission){
        Set<Id> monthlyCommissionIds = new Set<Id>();
        for(Monthly_Commission__c monthlyCommission : listMonthlyCommission)
        {
            monthlyCommissionIds.add(monthlyCommission.id); 
        }
        Map<String,Map<Id,List<Monthly_Breakdown__c>>> monthlyBreakdownByMonthlyCommissionByProfile = new Map<String,Map<Id,List<Monthly_Breakdown__c>>>();
        
        List<Monthly_Breakdown__c> listMonthlyBreakdown = MonthlyBreakdownSelector.getMonthlyBreakDownByMonthlyCommission(monthlyCommissionIds);
        
        for(Monthly_Breakdown__c monthlyBreakdown : listMonthlyBreakdown)
        {
            if(monthlyBreakdownByMonthlyCommissionByProfile.containsKey(monthlyBreakdown.monthly_commission__r.employee__r.profile.name))
            {
                if(monthlyBreakdownByMonthlyCommissionByProfile.get(monthlyBreakdown.monthly_commission__r.employee__r.profile.name).containskey(monthlyBreakdown.Monthly_Commission__c))
                {
                    monthlyBreakdownByMonthlyCommissionByProfile.get(monthlyBreakdown.monthly_commission__r.employee__r.profile.name).get(monthlyBreakdown.Monthly_Commission__c).add(monthlyBreakdown);
                }
                else{
                    monthlyBreakdownByMonthlyCommissionByProfile.get(monthlyBreakdown.monthly_commission__r.employee__r.profile.name).put(monthlyBreakdown.Monthly_Commission__c,new List<monthly_breakdown__c>{monthlyBreakdown});  
                }
            }
            else{
                monthlyBreakdownByMonthlyCommissionByProfile.put(monthlyBreakdown.monthly_commission__r.employee__r.profile.name,new Map<id,List<Monthly_Breakdown__c>>{monthlyBreakdown.Monthly_Commission__c => new List<monthly_breakdown__c>{monthlyBreakdown}});
            }
        }
        for(String profile : monthlyBreakdownByMonthlyCommissionByProfile.keySet())
        {
            if(profile == CommissionCalculatorConstants.REPTYPEAD){
            List<Monthly_Commission__c> lstMonthlyCommission = EmployeeMonthlyCommissionHelper.calculateMonthlyCommissionAnDBases(monthlyBreakdownByMonthlyCommissionByProfile.get(profile));
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        
    }
}