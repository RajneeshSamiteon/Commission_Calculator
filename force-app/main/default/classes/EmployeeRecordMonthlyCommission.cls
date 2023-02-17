/* 
    ==> This batch will create one record every month at date 1 for active user which has profile A&D.
   */

   public class EmployeeRecordMonthlyCommission implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        try{
            String profileName = CommissionCalculatorConstants.salesRepADProfile; 
            String userListOnProfileBasis = 'Select Id,Name from User where User.Profile.Name=:'+'profileName'+' AND IsActive=true AND Dont_calculate_commission__c = false';
            return Database.getQueryLocator(userListOnProfileBasis);  
        }
        catch(DmlException e) {
            ExceptionUtils.createExceptionLogV2('Monthly_Commission__c',e.getMessage(),e.getStackTraceString());
            return null;
        }
    }
    public void execute(Database.BatchableContext BC, list<User> userListOnProfileBasis){
        try{
            List<Monthly_Commission__c> listMonthlyCommission = new List<Monthly_Commission__c>();
            Map<String,String> eoySalesCommissionByEmployee = new Map<String,String>();
            String recordTypeId = Schema.SObjectType.Commission_Master__c.getRecordTypeInfosByName().get('Sales Rep A&D').getRecordTypeId();
            List<EoY_Sales_Commission__c> listEoYSalesCommission = EoYSalesCommissionSelector.getEoYSalesCommission(recordTypeId);
            for(EoY_Sales_Commission__c eoySalesCommission : listEoYSalesCommission){
                eoySalesCommissionByEmployee.put(eoySalesCommission.Employee__c,eoySalesCommission.Id);
            }
            for(User user : userListOnProfileBasis){
                if(eoySalesCommissionByEmployee.containsKey(user.Id)){
                    Monthly_Commission__c monthlyCommission = new Monthly_Commission__c();
                    monthlyCommission.EoY_Sales_Commission__c = eoySalesCommissionByEmployee.get(user.Id);
                    listMonthlyCommission.add(monthlyCommission);                    
                }
            }
            if(listMonthlyCommission != null){
                insert listMonthlyCommission; 
            }
        }
        catch(DmlException e) {
            ExceptionUtils.createExceptionLogV2('Monthly_Commission__c',e.getMessage(),e.getStackTraceString());
        }
    }
    public void finish(Database.BatchableContext BC){
        
    }
}