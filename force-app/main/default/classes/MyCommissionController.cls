public class MyCommissionController {
    @AuraEnabled
    public static User getLoggedInUser(){
        try{
            return UserSelector.getUsersByUserIds(new Set<Id>{userInfo.getUserId()}).values()[0];
        }
        catch(DmlException err){
            System.debug('Exp===>'+err.getMessage());
            throw new AuraHandledException(err.getMessage() +'Trace'+ err.getStackTraceString());
        }
    }
    @AuraEnabled(cacheable = true)
    public static MCCommissionData getMonthlyBreakDown(string month , string userName){
        try{
            String profileName = 'Sales Representative - A&D';
            Id recordTypeID = Schema.SObjectType.Commission_Master__c.getRecordTypeInfosByName().get(profileName).getRecordTypeId();
            MCCommissionData myCommissionData = new MCCommissionData();
            myCommissionData.monthlyBreakDown =  MonthlyBreakdownSelector.getMonthlyBreakDownForCurrentLoggedInUser();
            myCommissionData.monthlyCommission = MonthlyCommissionSelector.getMonthlyCommissionByEmployeeAndBreakDown(Datafactory.getFieldIdFromsObjects
                                                                                                                      (myCommissionData.monthlyBreakDown , 'Monthly_Commission__c'));
            return myCommissionData;
        }
        catch(DmlException err){
            System.debug('Exp===>'+err.getMessage());
            throw new AuraHandledException(err.getMessage() +'Trace'+ err.getStackTraceString());
        }
    }
    
    class MCCommissionData{
        
        @AuraEnabled public  list<monthly_breakDown__c> monthlyBreakDown{get;set;}
        @AuraEnabled public  list<monthly_commission__c> monthlyCommission{get;set;}
    }
    
}