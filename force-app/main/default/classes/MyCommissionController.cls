public class MyCommissionController {
    @AuraEnabled
    public static User getLoggedInUser(){
        return UserSelector.getUsersByUserIds(new Set<Id>{userInfo.getUserId()}).values()[0];
    }
    @AuraEnabled(cacheable = true)
    public static MCCommissionData getMonthlyBreakDown(user users, integer month){
        system.debug('user Object'+users);
        MCCommissionData mcCommissionData = new MCCommissionData();
        
        mcCommissionData.monthlyBreakDown =  MonthlyBreakdownSelector.getMonthlyBreakDownForCurrentLoggedInUser();
        return mcCommissionData;
    }
    
    class MCCommissionData{
        
       @AuraEnabled public  list<monthly_breakDown__c> monthlyBreakDown{get;set;}
       @AuraEnabled public  list<monthly_commission__c> monthlyCommission{get;set;}
    }
    
}