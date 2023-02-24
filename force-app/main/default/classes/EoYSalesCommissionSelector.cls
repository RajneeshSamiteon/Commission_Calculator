public class EoYSalesCommissionSelector {
    public static List<EoY_Sales_Commission__c> getEoYSalesCommission(String recordTypeId){
            return [Select Id,Name,Employee__c from EoY_Sales_Commission__c where createdDate = THIS_YEAR ];
    
    }
}