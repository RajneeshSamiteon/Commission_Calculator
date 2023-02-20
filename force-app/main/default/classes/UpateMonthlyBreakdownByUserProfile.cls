public class UpateMonthlyBreakdownByUserProfile {
    public static void updateMonthlyBreakdownForAandD(Map<Id,list<InvoiceDetailTriggerHelper.SplitDetails>> splitsbyOppportunity , Map<String,Map<Id,InvoiceDetailTriggerHelper.InvoiceMargins>> calculatedMarginsByOpportunityIdByMonth) {
      //  Map<id, InvoiceMargins> previousMonthOrYearInvoices = new Map<id , InvoiceMargins>();
       // String currentMonthAndYear = CommissionCalculatorConstants.MONTHBYNUMBER.get(date.today().month())+ '-'+ String.valueOf(date.today().year());   
       Integer i=0;
        for(id opportunityId : splitsbyOppportunity.keySet())
        {
            for(string invoiceMonthAndYear : calculatedMarginsByOpportunityIdByMonth.keySet() ){
                if(calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).containsKey(opportunityId))
                {
                    InvoiveMargis obj = new calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).get(opportunityId);
                    //calculateCommissionForSalesRepAandD(calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).get(opportunityId) , splitsbyOppportunity.get(opportunityId));
                    for(InvoiceDetailTriggerHelper.SplitDetails splits : splitsbyOppportunity.get(opportunityId))
                    {
                        if(InvoiceDetailTriggerHelper.monthlyBreakDownsByOpportunity.containsKey(opportunityId))
                        {
                            for(Monthly_Breakdown__c breakDown : InvoiceDetailTriggerHelper.monthlyBreakDownsByOpportunity.get(opportunityId))
                            {
                                if(breakDown.monthly_commission__r.Employee__c == splits.ownerId && breakDown.monthly_commission__r.name.contains(invoiceMonthAndYear) && breakDown.opportunity__c == opportunityId){
                                    //breakDown.
                                   break; 
                                }
                                else {
                                    i++;
                                }
                            }
                        }
                        else {
                            //create a new breakDown
                        }
                        
                    }
                }
            }
        }
    }
    /*public void calculateCommissionForSalesRepAandD(InvoiceMargins invoice , list<SplitDetails> SplitaDetails){

    }*/
    public class SlabDetailsForAandD {
        public Integer minAmount;
        public Integer maxAmount;
        public Decimal commissionPercent;
        public Slab(Integer minAmount, Integer maxAmount, Decimal commissionPercent) {
            this.minAmount = minAmount;
            this.maxAmount = maxAmount;
            this.commissionPercent = commissionPercent;
        }
    }
}