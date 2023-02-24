public class EmployeeMonthlyCommissionHelper{
    public static List<Monthly_Commission__c> calculateMonthlyCommissionAnDBases(Map<Id,List<Monthly_Breakdown__c>> mothlyBreakdownByMonthlyCommission){
        List<Monthly_Commission__c> listMonthlyCommission = new List<Monthly_Commission__c>();
        for(List<Monthly_Breakdown__c> listMonthlyBreackdown : mothlyBreakdownByMonthlyCommission.values()){
            for(Monthly_Breakdown__c monthlyBreackdown : listMonthlyBreackdown){
                Monthly_Commission__c monthlyCommission = new Monthly_Commission__c();
                monthlyCommission.Id = monthlyBreackdown.Monthly_Commission__c;
                monthlyCommission.Ancillary_Margin__c += monthlyBreackdown.Ancillary_Margin__c;
                monthlyCommission.Tile_Margin__c += monthlyBreackdown.Tile_margin__c;
                monthlyCommission.Eligible_Margin__c += monthlyBreackdown.Elgible_Amount__c;
                monthlyCommission.Not_Elligible_Margin__c = ((monthlyCommission.Tile_Margin__c -  monthlyCommission.Ancillary_Margin__c)-monthlyCommission.Eligible_Margin__c);
                monthlyCommission.Tile_Sale__c += monthlyBreackdown.tile_sale__c;
                monthlyCommission.Ancillary_Sale__c += monthlyBreackdown.ancillary_sale__c;
                monthlyCommission.Ancillary_Margin_Percent__c = ((monthlyCommission.Ancillary_Margin__c/monthlyCommission.Ancillary_Sale__c)*100).setscale(2);
                monthlyCommission.Tile_Margin_Percent__c = ((monthlyCommission.Tile_Margin__c/monthlyCommission.Tile_Sale__c)*100).setscale(2);
                if( monthlyCommission.Tile_Margin_Percent__c >= 33.0 && monthlyCommission.Ancillary_Margin_Percent__c >= 28.0)
                {
                    monthlyCommission.Target_Met__c = true;
                }
                else{
                    monthlyCommission.Target_Met__c = false;
                }
                listMonthlyCommission.add(monthlyCommission);
            }
        }
        return listMonthlyCommission;
    }
}