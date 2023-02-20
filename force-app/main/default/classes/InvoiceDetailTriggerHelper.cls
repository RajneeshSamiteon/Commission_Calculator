public class InvoiceDetailTriggerHelper {
    
    /************************************************

    => we'll be segregating our data and passing them 
    to different methods.  
    
    => EvaluatedInvoicesByOpportunity map stores 
    all the sagregated invoice commission bases 
    on opportunity owner
    
    => EvaluatedInvoicesByAccount map stores all 
    the sagregated invoice commission bases on 
    account owner

    *************************************************/
    
    Map<String,Map<Id,InvoiceMargins>> calculatedMarginsByOpportunityIdByMonth = new Map<String,Map<Id,InvoiceMargins>>();
    Map<String,Map<Id,InvoiceMargins>> calculatedMarginsByAccountIdByMonth = new Map<String,Map<Id,InvoiceMargins>>();
    Map<String,Map<Id,list<SplitDetails>>> splitsByOpportunityIdByProfileName = new Map<String,Map<Id,list<SplitDetails>>>();
    Map<String,Map<Id,list<SplitDetails>>> splitsByAccountIdByProfileName = new Map<String,Map<Id,list<SplitDetails>>>();
    Map<id,list<monthly_breakdown__c>> monthlyBreakdownsByOpportunity = new Map<Id,List<monthly_breakdown__c>>();
    Map<id,list<monthly_breakdown__c>> monthlyBreakdownsByAccount = new Map<Id,List<monthly_breakdown__c>>();
    Set<id> opportunityIds = new Set<id>();
    Set<id> accountIds = new Set<id>();
    Map<Id,Monthly_Commission__c> monthlyCommissionsById = new Map<Id,Monthly_Commission__c>();  
    List<Monthly_Breakdown__c> monthlyBreakdownsToBeUpserted = new List<Monthly_Breakdown__c>();
    
    
    public void commissionCalculator(List<Invoice_detail__c> invoicesDetails)
    {        
        Integer i=0;
        Integer monthlyBreakdownsSize = 0;   
        populateCommissionMarginsSchema(invoicesDetails);
        populateSplitsSchema();
        this.monthlyCommissionsById = getMonthlyCommissionViaNameAndEmployee();
        populateMonthlyBreakdownSchema(this.monthlyCommissionsById.keyset());
        /// Iterating the splitsByOpportunityIdByProfileName Map to call different method for further calclation now at profile level
        for(String profileName : this.splitsByOpportunityIdByProfileName.keySet()){
            if(profileName == CommissionCalculatorConstants.REPTYPEAD)
            {
                populateMonthlyBreakdownsToBeUpsertedForAnD(this.splitsByOpportunityIdByProfileName.get(profileName),i,monthlyBreakdownsSize);
            }
        }
        
    }
    
    public void populateCommissionMarginsSchema(List<Invoice_detail__c> invoicesDetails){
        System.debug('Entring:populateCommissionMarginsSchem => invoicesDetails'+invoicesDetails);
        for(Invoice_detail__c invoiceDetail : invoicesDetails)
        {
            String invoiceMonthAndYear = CommissionCalculatorConstants.MONTHBYNUMBER.get(InvoiceDetail.Invoice_Date__c.month())+ '-'+ String.valueOf(invoiceDetail.Invoice_Date__c.year());
            if(invoiceDetail.Opportunity__c != null)
            {
                if(this.calculatedMarginsByOpportunityIdByMonth.containsKey(invoiceMonthAndYear))
                {
                    if(this.calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).containsKey(invoiceDetail.Opportunity__c))
                    {
                        this.calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).put(invoiceDetail.Opportunity__c,
                                                                                                      this.calucluateInvoiceMargins(this.calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).get(invoiceDetail.Opportunity__c),
                                                                                                                                    invoiceDetail));    
                    }
                    else {
                        this.opportunityIds.add(invoiceDetail.Opportunity__c);
                        this.calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).put(invoiceDetail.Opportunity__c,
                                                                                                      this.calucluateInvoiceMargins(New InvoiceMargins(),
                                                                                                                                    invoiceDetail));    
                    }
                }
                else {
                    this.opportunityIds.add(invoiceDetail.Opportunity__c);
                    this.calculatedMarginsByOpportunityIdByMonth.put(invoiceMonthAndYear , 
                                                                     new map<Id,InvoiceMargins>{invoiceDetail.Opportunity__c => this.calucluateInvoiceMargins(New InvoiceMargins(),
                                                                                                                                                              invoiceDetail)});
                }
            }
            else 
            {
                if(this.calculatedMarginsByAccountIdByMonth.containsKey(invoiceMonthAndYear))
                {
                    if(this.calculatedMarginsByAccountIdByMonth.get(invoiceMonthAndYear).containsKey(invoiceDetail.Account__c))
                    {
                        this.calculatedMarginsByAccountIdByMonth.get(invoiceMonthAndYear).put(invoiceDetail.Account__c,
                                                                                                  this.calucluateInvoiceMargins(this.calculatedMarginsByAccountIdByMonth.get(invoiceMonthAndYear).get(invoiceDetail.Account__c),
                                                                                                                                invoiceDetail));    
                    }
                    else {
                        this.accountIds.add(invoiceDetail.Account__c);
                        this.calculatedMarginsByAccountIdByMonth.get(invoiceMonthAndYear).put(invoiceDetail.Account__c,
                                                                                                  this.calucluateInvoiceMargins(New InvoiceMargins(),
                                                                                                                                invoiceDetail));    
                    }
                }
                else {
                    this.accountIds.add(invoiceDetail.Account__c);
                    this.calculatedMarginsByAccountIdByMonth.put(invoiceMonthAndYear , 
                                                                 new map<Id,InvoiceMargins>{invoiceDetail.Account__c => this.calucluateInvoiceMargins(New InvoiceMargins(),
                                                                                                                                                      invoiceDetail)});
                }
            }
        }
        System.debug('Exit:populateCommissionMarginsSchema =>  calculatedMarginsByOpportunityIdByMonth::'+
                     this.calculatedMarginsByOpportunityIdByMonth+'\n calculatedMarginsByAccountIdByMonth::'+
                     this.calculatedMarginsByAccountIdByMonth);
    }
    
    public InvoiceMargins calucluateInvoiceMargins(InvoiceMargins preEvaluatedInvoice , Invoice_detail__c invoiceDetail){	
        preEvaluatedInvoice.totalSales += invoiceDetail.Item_Price__c;
        if(invoiceDetail.Item_Group__c == commissionCalculatorconstants.itemGroupTile)
        {
            preEvaluatedInvoice.tileSales += invoiceDetail.Item_Price__c;
            preEvaluatedInvoice.tileMargin += (invoiceDetail.Item_Price__c - invoiceDetail.Item_cost__c);
            preEvaluatedInvoice.tileMarginPercentage = ((preEvaluatedInvoice.tileMargin /preEvaluatedInvoice.tileSales) *100).setScale(2);
        }
        else
        {
            preEvaluatedInvoice.AncillarySales += invoiceDetail.Item_Price__c;
            preEvaluatedInvoice.AncillaryMargin += (invoiceDetail .Item_Price__c - invoiceDetail.Item_cost__c);
            preEvaluatedInvoice.ancillaryMarginPercentage = ((preEvaluatedInvoice.AncillaryMargin / preEvaluatedInvoice.AncillarySales) *100).setScale(2);
        }
        return preEvaluatedInvoice;
    } 
    
    public void populateSplitsSchema(){
        System.debug('Entring:populateSplitsSchema');
        Set<Id> oppotunityIdsToBeRemovedFromOpportunityIds = new Set<Id>();
        for(OpportunitySplit split :OpportunitySplitSelector.getOpportunitySplitByOpportunity(this.opportunityIds)){            
            if(this.splitsByOpportunityIdByProfileName.containsKey(split.SplitOwner.Profile.Name))
            {
                if(this.splitsByOpportunityIdByProfileName.get(split.SplitOwner.Profile.Name).containsKey(split.opportunityId))
                {
                    this.splitsByOpportunityIdByProfileName.get(split.SplitOwner.Profile.Name).get(split.opportunityId).add(New SplitDetails(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage));   
                }
                else {
                    this.splitsByOpportunityIdByProfileName.get(split.SplitOwner.Profile.Name)
                        .put(split.opportunityId ,New List<SplitDetails>{new SplitDetails(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage)});   
                }
            }
            else {
                this.splitsByOpportunityIdByProfileName.put(split.SplitOwner.Profile.Name ,
                                                            new map<id,list<SplitDetails>>{split.OpportunityId => 
                                                                New List<SplitDetails>{New SplitDetails(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage)}});
            }
            oppotunityIdsToBeRemovedFromOpportunityIds.add(split.opportunityId);
        }
        this.opportunityIds.removeAll(oppotunityIdsToBeRemovedFromOpportunityIds);
        updateSplitsByOpportunityIdByProfileNameWithRemainingOpportunities();
        updateSplitsByAccountIdByProfileName();
        System.debug('Exit:populateSplitsSchema =>  splitsByOpportunityIdByProfileName::'+
                     this.splitsByOpportunityIdByProfileName);
    }
    
    public void updateSplitsByOpportunityIdByProfileNameWithRemainingOpportunities(){
        System.debug('Entring:updateSplitsByOpportunityIdByProfileNameWithRemainingOpportunities');
        for(Opportunity opportunity :OpportunitySelector.getOpportunitiesById(this.opportunityIds)){
            if(this.splitsByOpportunityIdByProfileName.containsKey(opportunity.owner.profile.Name)){
                if(this.splitsByOpportunityIdByProfileName.get(opportunity.owner.profile.Name).containsKey(opportunity.id)){
                    this.splitsByOpportunityIdByProfileName.get(opportunity.owner.profile.Name).get(opportunity.id).add(New SplitDetails(opportunity.OwnerId,opportunity.owner.profile.name,CommissionCalculatorConstants.MARGINPERCENTFOROPPWITHNOSPLITS));   
                } 
                else{
                    this.splitsByOpportunityIdByProfileName.get(opportunity.owner.profile.Name)
                        .put(opportunity.id ,New List<SplitDetails> {new SplitDetails(opportunity.OwnerId,opportunity.owner.profile.name,CommissionCalculatorConstants.MARGINPERCENTFOROPPWITHNOSPLITS)});   
                }
            }
            else {
                this.splitsByOpportunityIdByProfileName
                    .put(opportunity.owner.profile.Name ,new map<id,list<SplitDetails>>{opportunity.id => New List<SplitDetails>{New SplitDetails(opportunity.OwnerId,opportunity.owner.profile.name,CommissionCalculatorConstants.MARGINPERCENTFOROPPWITHNOSPLITS)}});
            }
        }
        System.debug('Exit:updateSplitsByOpportunityIdByProfileNameWithRemainingOpportunities');
    }
    
    public void updateSplitsByAccountIdByProfileName(){
        System.debug('Entring:updateSplitsByAccountIdByProfileName');
        for(Account account : AccountSelector.getAccountById(this.accountIds)){
            if(this.splitsByAccountIdByProfileName.containsKey(account.Owner.Profile.Name)){
                if(this.splitsByAccountIdByProfileName.get(account.Owner.Profile.Name).containsKey(account.id)){
                    this.splitsByAccountIdByProfileName.get(account.Owner.Profile.Name).get(account.id).add(New SplitDetails(account.OwnerId,account.Owner.Profile.Name,CommissionCalculatorConstants.MARGINPERCENTFORACCOUNTS));   
                } 
                else{
                    this.splitsByAccountIdByProfileName.get(account.Owner.Profile.Name)
                        .put(account.id ,New  List<SplitDetails> {new SplitDetails(account.OwnerId,account.Owner.Profile.Name,CommissionCalculatorConstants.MARGINPERCENTFORACCOUNTS)});   
                }
            }
            else {
                this.splitsByAccountIdByProfileName.put(account.Owner.Profile.Name ,new map<id,list<SplitDetails>>{account.id => New List<SplitDetails>{New SplitDetails(account.OwnerId,account.Owner.Profile.Name,CommissionCalculatorConstants.MARGINPERCENTFORACCOUNTS)}});
            }
        }
        System.debug('Exit:updateSplitsByAccountIdByProfileName =>  splitsByAccountIdByProfileName::'+
                     this.splitsByAccountIdByProfileName);
    }
    
    public Map<Id,Monthly_Commission__c> getMonthlyCommissionViaNameAndEmployee(){
        System.debug('Entering:getMonthlyCommissionViaNameAndEmployee');
        String query = 'SELECT Id, Name, Employee__c, EoY_Sales_Commission__c, Tile_Margin__c, Tile_Margin_Percent__c, Target_Met__c, Price__c, Not_Elligible_Margin__c, Month__c, Margin__c, Eligible_Margin__c, Date__c, Cost__c, Ancillary_Margin__c, Ancillary_Margin_Percent__c FROM Monthly_Commission__c';
        String whereClause = ' WHERE Name Like \'%';
        Set<String> nameClauseSetup = calculatedMarginsByOpportunityIdByMonth.keySet();
        Set<Id> userIds = new Set<Id>();
        nameClauseSetup.addAll(calculatedMarginsByAccountIdByMonth.keySet());
        List<String> nameClause = new List<String>(nameClauseSetup);
        whereClause += String.join(nameClause, '\' OR Name Like \'%');
        whereClause += '\' AND';
        userIds = getUserIdsFromSchema(this.splitsByOpportunityIdByProfileName.values(),userIds);
        userIds = getUserIdsFromSchema(this.splitsByAccountIdByProfileName.values(),userIds);
        whereClause += ' Employee__c IN : userIds';
        query += whereClause;
        system.debug('query::'+query);
        List<Monthly_Commission__c> monthlyCommissionViaNameAndEmployee = Database.query(query);
        Map<Id,Monthly_Commission__c> monthlyCommissionById = new Map<Id,Monthly_Commission__c>(monthlyCommissionViaNameAndEmployee);
        system.debug('Exit:getMonthlyCommissionViaNameAndEmployee => monthlyCommissionById:'+monthlyCommissionById); 
        return monthlyCommissionById;
    }
    
    public Set<id> getUserIdsFromSchema(List<Map<Id,list<SplitDetails>>> splitDetailsById,Set<id> userIds){
	    System.debug('Entering:getUserIdsFromSchema => splitDetailsById::'+splitDetailsById+'\n userIds::'+userIds);
        for(Map<Id,list<SplitDetails>> splitDetailById :splitDetailsById){
            for(SplitDetails detail: splitDetailById.values()[0]){
                userIds.add(detail.ownerId);
            }
        }
        System.debug('Exit:getUserIdsFromSchema => userIds::'+userIds);
        return userIds;
    }
    
    /* populateMonthlyBreakdownSchema Method populates
     * monthlyBreakDownsByOpportunity and monthlyBreakDownsByAccount
     * attributes.
     */
    
    public void populateMonthlyBreakdownSchema(Set<id> monthlyCommissions){
        System.debug('Entering:populateMonthlyBreakdownSchema => monthlyCommissions::'+monthlyCommissions);
        for(Monthly_Breakdown__c monthlyBreakdown : MonthlyBreakdownSelector.getMonthlyBreakDownByMonthlyCommission(monthlyCommissions)){
            if(monthlyBreakdown.Opportunity__c != null)
            {
                if(this.monthlyBreakdownsByOpportunity.containsKey(monthlyBreakdown.Opportunity__c))
                {
                    this.monthlyBreakdownsByOpportunity.get(monthlyBreakdown.Opportunity__c).add(monthlyBreakdown);
                }
                else {
                    this.monthlyBreakdownsByOpportunity.put(monthlyBreakdown.Opportunity__c ,  new List<Monthly_Breakdown__c>{monthlyBreakdown});
                }
                
            }
            else
            {
                if(this.monthlyBreakdownsByAccount.containsKey(monthlyBreakdown.Account__c))
                {
                    this.monthlyBreakdownsByAccount.get(monthlyBreakdown.Account__c).add(monthlyBreakdown);
                }
                else {
                    this.monthlyBreakdownsByAccount.put(monthlyBreakdown.Account__c ,  new List<Monthly_Breakdown__c>{monthlyBreakdown});
                }
            }
        }
        System.debug('Exit:populateMonthlyBreakdownSchema =>  monthlyBreakDownsByOpportunity::'+
                     this.monthlyBreakDownsByOpportunity+'\n monthlyBreakDownsByAccount::'+
                     this.monthlyBreakDownsByAccount);
    }

    /*
     * populateMonthlyBreakdownsToBeUpsertedForAnD method is base method 
     * in which there are sub methods that are processing Splits,Margins,
     * Monthly Commissions and Monthly Breakdowns. If Breakdown exists then it'll
     * be updated with new data and if not it'll create a new breakdown
     */
    public void populateMonthlyBreakdownsToBeUpsertedForAnD(Map<Id,List<SplitDetails>> splitsbyOppportunity, Integer  i, Integer monthlyBreakdownsSize) {
        System.debug('Entering:populateMonthlyBreakdownsToBeUpsertedForAnD => splitsbyOppportunity::'+splitsbyOppportunity);
        for(id opportunityId : splitsbyOppportunity.keySet()){
            for(string invoiceMonthAndYear : this.calculatedMarginsByOpportunityIdByMonth.keySet()){
                if(this.calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).containsKey(opportunityId)){
                    setupCalculationRelatedDataForMonthlyBreakdown(opportunityId,invoiceMonthAndYear,splitsbyOppportunity,i,monthlyBreakdownsSize);
                }
            }
        }
        System.debug('Exit:populateMonthlyBreakdownsToBeUpsertedForAnD =>  monthlyBreakdownsToBeUpserted::'+
                     JSON.serializePretty(this.monthlyBreakdownsToBeUpserted));
    }
    
    public void setupCalculationRelatedDataForMonthlyBreakdown(id opportunityId, String invoiceMonthAndYear, Map<Id,List<SplitDetails>> splitsbyOppportunity,
                                                                Integer i, Integer monthlyBreakdownsSize){
        InvoiceMargins invoiceMargin = new InvoiceMargins(this.calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).get(opportunityId));
        //calculateCommissionForSalesRepAandD(this.calculatedMarginsByOpportunityIdByMonth.get(invoiceMonthAndYear).get(opportunityId) , splitsbyOppportunity.get(opportunityId));
        for(SplitDetails splitDetail : splitsbyOppportunity.get(opportunityId)){
            if(this.monthlyBreakDownsByOpportunity.containsKey(opportunityId)){
                i=0;
                monthlyBreakdownsSize = this.monthlyBreakDownsByOpportunity.get(opportunityId).size();
                for(Monthly_Breakdown__c breakDown : this.monthlyBreakDownsByOpportunity.get(opportunityId)){
                    if(breakDown.monthly_commission__r.Employee__c == splitDetail.ownerId && 
                       breakDown.monthly_commission__r.name.contains(invoiceMonthAndYear) && 
                       breakDown.opportunity__c == opportunityId){
                        updateExistingMonthlyBreakdown(breakDown,invoiceMargin,splitDetail.split);
                        break; 
                    }
                    i++;
                }
                if(i == monthlyBreakdownsSize){
                    updateMonthlyBreakdownsToBeUpsertedWithNewBreakdown(opportunityId, splitDetail.ownerId, splitDetail.split, invoiceMonthAndYear,invoiceMargin);
                }
            }
            else {
                updateMonthlyBreakdownsToBeUpsertedWithNewBreakdown(opportunityId, splitDetail.ownerId, splitDetail.split, invoiceMonthAndYear,invoiceMargin);
            }
            
        }
    }
    
    public void updateExistingMonthlyBreakdown(Monthly_Breakdown__c monthlyBreakdown, InvoiceMargins invoiceMargin,Decimal splitPercentage){
        monthlyBreakdown.Total_sales__c += invoiceMargin.totalSales;
        monthlyBreakdown.Tile_Sale__c += invoiceMargin.tileSales;
        monthlyBreakdown.ancillary_sale__c += invoiceMargin.ancillarySales;
        monthlyBreakdown.Tile_Margin__c  +=invoiceMargin.tileMargin;
        monthlyBreakdown.Ancillary_Margin__c += invoiceMargin.ancillaryMargin;
        monthlyBreakdown.Commission_Split_Percentage__c  = splitPercentage;
        monthlyBreakdown = calculateMonthlyBreakdownMargins(monthlyBreakdown);
        this.monthlyBreakdownsToBeUpserted.add(monthlyBreakdown);
    
    }
    
    public Monthly_Breakdown__c calculateMonthlyBreakdownMargins(Monthly_Breakdown__c monthlyBreakdown){
        monthlyBreakdown.Tile_Margin_Percentage__c  = ((monthlyBreakdown.Tile_Margin__c / monthlyBreakdown.Tile_Sale__c) *100).setScale(2);
        monthlyBreakdown.Ancillary_Margin_Percentage__c  = ((monthlyBreakdown.Ancillary_Margin__c / monthlyBreakdown.ancillary_sale__c) *100).setScale(2);
        monthlyBreakdown.Total_Invoice_Tile_Margin__c  = ((monthlyBreakdown.Tile_Margin__c  * monthlyBreakdown.Commission_Split_Percentage__c)/100).setScale(2);
        monthlyBreakdown.Total_Invoice_Ancillary_Margin__c   = ((monthlyBreakdown.Ancillary_Margin__c  * monthlyBreakdown.Commission_Split_Percentage__c)/100).setScale(2);
        monthlyBreakdown.Total_Margin__c = monthlyBreakdown.Total_Invoice_Tile_Margin__c + monthlyBreakdown.Total_Invoice_Ancillary_Margin__c;
        if( monthlyBreakdown.Tile_Margin_Percentage__c >= 33.0 && monthlyBreakdown.Ancillary_Margin_Percentage__c >= 28.0){
            monthlyBreakdown.Met_Margin__c = true;
        }
        else{
            monthlyBreakdown.Met_Margin__c = false;
        }
        if(monthlyBreakdown.Met_Margin__c){
            monthlyBreakdown.Elgible_Amount__c = monthlyBreakdown.Total_Margin__c;
        }
        else{
            monthlyBreakdown.Elgible_Amount__c = 0;
        }
        return monthlyBreakdown;
    }
  
    public void updateMonthlyBreakdownsToBeUpsertedWithNewBreakdown(Id opportunityId, Id splitOwnerId,Decimal splitPercentage, String invoiceMonthAndYear, InvoiceMargins invoiceMargin){
        Monthly_Breakdown__c monthlyBreakdown = new Monthly_Breakdown__c();
        monthlyBreakdown.opportunity__c = opportunityId;
        monthlyBreakdown.monthly_commission__c = getMonthlyCommissionViaSplitOwnerIdAndInvoiceDate(splitOwnerId, invoiceMonthAndYear);
        monthlyBreakdown.Total_sales__c = invoiceMargin.totalSales;
        monthlyBreakdown.Tile_Sale__c = invoiceMargin.tileSales;
        monthlyBreakdown.ancillary_sale__c = invoiceMargin.ancillarySales;
        monthlyBreakdown.Tile_Margin__c  =invoiceMargin.tileMargin;
        monthlyBreakdown.Ancillary_Margin__c = invoiceMargin.ancillaryMargin;
        monthlyBreakdown.Commission_Split_Percentage__c  = splitPercentage;
        monthlyBreakdown = calculateMonthlyBreakdownMargins(monthlyBreakdown);
        this.monthlyBreakdownsToBeUpserted.add(monthlyBreakdown);
    }

    public id getMonthlyCommissionViaSplitOwnerIdAndInvoiceDate (id splitOwnerId, String invoiceMonthAndYear){
        Id monthlyCommission;
        for(Monthly_Commission__c commission : this.monthlyCommissionsById.values()){
            if(commission.Employee__c == splitOwnerId && commission.name.contains(invoiceMonthAndYear)){
                monthlyCommission = commission.Id;
                break;
            }
        }
        return monthlyCommission;
    }

    public class InvoiceMargins {
        public Decimal totalSales;
        public Decimal tileSales;
        public Decimal ancillarySales;
        public Decimal tileMargin;
        public Decimal ancillaryMargin;
        public Decimal tileMarginPercentage;
        public Decimal ancillaryMarginPercentage;
        
        
        public invoiceMargins(){
            totalSales = 0 ;
            tileSales = 0;
            ancillarySales = 0;
            tileMargin = 0;
            ancillaryMargin = 0;
            tileMarginPercentage = 0;
            ancillaryMarginPercentage = 0;
        }
        
        public invoiceMargins(Decimal totalSales, Decimal tileSales, Decimal ancillarySales, Decimal tileMargin,
                              Decimal ancillaryMargin, Decimal tileMarginPercentage, Decimal ancillaryMarginPercentage){
                                  this.totalSales =totalSales;
                                  this.tileSales =tileSales;
                                  this.ancillarySales =ancillarySales;
                                  this.tileMargin =tileMargin;
                                  this.ancillaryMargin =ancillaryMargin;
                                  this.tileMarginPercentage =tileMarginPercentage;
                                  this.ancillaryMarginPercentage =ancillaryMarginPercentage;                              
                              }
        public invoiceMargins(InvoiceMargins invoiceMargin){
            this.totalSales =invoiceMargin.totalSales;
            this.tileSales =invoiceMargin.tileSales;
            this.ancillarySales =invoiceMargin.ancillarySales;
            this.tileMargin =invoiceMargin.tileMargin;
            this.ancillaryMargin =invoiceMargin.ancillaryMargin;
            this.tileMarginPercentage =invoiceMargin.tileMarginPercentage;
            this.ancillaryMarginPercentage =invoiceMargin.ancillaryMarginPercentage;         
        }
    }
    
    Public class SplitDetails{
        Public Id ownerId;
        Public String ownerProfile;
        Public Decimal split;
        Public SplitDetails(Id ownerId,String ownerProfile,Decimal split){
            this.ownerId = ownerId;
            this.ownerProfile = ownerProfile;
            this.split = split;
        }
    }
    
}