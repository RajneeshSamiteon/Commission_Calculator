public class UpateMonthlyBreakdownByUserProfile {
    public static void updateMonthlyBreakdownForAandD(list<Map<Id,list<SplitDetails>>> splitsbyOppportunity , Map<String,Map<Id,InvoiceMargins>> calculatedMarginsByOpportunityIdByMonth) {
        Map<id, InvoiceMargins> previousMonthOrYearInvoices = new Map<id , InvoiceMargins>();
        String currentMonthAndYear = CommissionCalculatorConstants.MONTHBYNUMBER.get(date.today().month())+ '-'+ String.valueOf(date.today().year());
        for(String opportunityMonthYear : calculatedMarginsByOpportunityIdByMonth.keySet())
        {
            if(opportunityMonthYear != currentMonthAndYear)
            {
                previousMonthOrYearInvoices.put(calculatedMarginsByOpportunityIdByMonth.get(opportunityMonthYear));
            }
            for(id OpportunityId : calculatedMarginsByOpportunityIdByMonth.get(opportunityMonthYear).keySet())
            {
                calculateCommissionForAandD(calculatedMarginsByOpportunityIdByMonth.get(opportunityMonthYear).values() , splitsbyOppportunity[0].get(OpportunityId));
            }
        }
    }
    public void calculateCommissionForAandD(InvoiceMargins invoice , list<SplitDetails> SplitaDetails){

        invoice.totalMargin = invoice.tileMargin+ invoice.ancillaryMargin;
        list<commission_tier__c> commissionTiers = new list<commission_tier__c>();
        commissionTiers= CommissionTierSelector.getCommissionTierByProfileName('Sales Rep A&D');
        Decimal amount = invoice.totalMargin;
        Decimal commission = 0.0;
        Integer remainingAmount = invoice.totalMargin;
        integer i = 1;
        for (commission_tier__c slab : commissionTiers) {
            
            if (amount <= slab.Upper_Amount__c) {
                commission += remainingAmount * slab.Commission_Percentage__c / 100;
            //    system.debug('remainingAmount <= slab.maxAmount: '+remainingAmount);
                break;
            } else {
                commission += (slab.Upper_Amount__c - slab.minAmount) * slab.Commission_Percentage__c / 100;
           //     system.debug('commission: '+commission);
                remainingAmount -= slab.Upper_Amount__c - slab.minAmount;
             //   system.debug('remainingAmount: '+remainingAmount);
            }
            i++;
        }

    }
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