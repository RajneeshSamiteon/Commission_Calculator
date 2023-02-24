public class EmployeeRecordEoYSalesCommission implements Database.Batchable<sObject>{
    /*******
    This method will query all the active user on the profile bases 
    ********/
   public Database.QueryLocator start(Database.BatchableContext BC) {
       try{
       String profileName = CommissionCalculatorConstants.REPTYPEAD; 
       String userListOnProfileBasis = 'Select Id,Name from User where User.Profile.Name=:profileName AND IsActive=true AND Dont_calculate_commission__c = false';
           return Database.getQueryLocator(userListOnProfileBasis);   
       }
      catch(DmlException e) {
           ExceptionUtils.createExceptionLogV2('EoY_Sales_Commission__c',e.getMessage(),e.getStackTraceString());
           return null;
       }
   }
   public void execute(Database.BatchableContext BC, list<User> userListOnProfileBasis){
       try {
       List<EoY_Sales_Commission__c> listEoYSalesCommission = new List<EoY_Sales_Commission__c>();
       Id recordTypeId = Schema.SObjectType.Commission_Master__c.getRecordTypeInfosByName().get('Sales Rep A&D').getRecordTypeId();
       Id commissionMasterId = CommissionMasterSelector.getCommissionMasterRecordTypeBases(recordTypeId);
       for(User user : userListOnProfileBasis){
           EoY_Sales_Commission__c salesCommissionEoY = new EoY_Sales_Commission__c();
           salesCommissionEoY.Employee__c = user.Id;
           salesCommissionEoY.Commission_Master__c = commissionMasterId;
           listEoYSalesCommission.add(salesCommissionEoY);
       }
            insert listEoYSalesCommission;
       } 
       catch(DmlException e) {
           ExceptionUtils.createExceptionLogV2('EoY_Sales_Commission__c',e.getMessage(),e.getStackTraceString());
       }
   }
   public void finish(Database.BatchableContext BC){
       
   }
}