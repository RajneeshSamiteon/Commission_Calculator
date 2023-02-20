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
    
    Map<String,Map<Id,InvoiceMargins>> calculatedMarginsByOpportunityIdByMonth = New Map<String,Map<Id,InvoiceMargins>>();
    Map<String,Map<Id,InvoiceMargins>> calculatedMarginsByAccountIdByMonth = New Map<String,Map<Id,InvoiceMargins>>();
    Map<string,Map<Id,list<SplitDetails>>> splitsByOpportunityIdByProfileName = New Map<string,Map<Id,list<SplitDetails>>>();
    Map<string,Map<Id,list<SplitDetails>>> splitsByAccountIdByProfileName = New Map<string,Map<Id,list<SplitDetails>>>();

    Map<id,list<monthly_breakdown__c>> monthlyBreakDownsByOpportunity = New Map<string,list<monthly_breakdown__c>>();
    Map<id,list<monthly_breakdown__c>> monthlyBreakDownsByAccount = New Map<string,list<monthly_breakdown__c>>();
    Set<id> opportunityIds = new Set<id>();
    Set<id> accountIds = new Set<id>();
    
    
    public void commissionCalculator(List<Invoice_detail__c> invoicesDetails)
    {        
        Map<Id,Monthly_Commission__c> monthlyCommissionsById = new Map<Id,Monthly_Commission__c>();      
        Map<id ,monthly_breakdown__c> monthlyBreakDown = new Map<id ,monthly_breakdown__c>();
        populateCommissionMarginsSchema(invoicesDetails);
        populateSplitsSchema();
        monthlyCommissionsById = getMonthlyCommissionViaNameAndEmployee();
        monthlyBreakDown = getMonthlyBreakDownViaMonthlyCommission(monthlyCommissionsById.keyset());
        /// looping the SplitByOpportunity Map to call different method for further calclation now at profile level
        for(String profileName : splitsByOpportunityIdByProfileName.keySet()){
            if(profileName == 'Sales Rep A&D')
            {
                UpateMonthlyBreakdownByUserProfile.updateMonthlyBreakdownForAandD(splitsByOpportunityIdByProfileName.get(profileName) ,calculatedMarginsByOpportunityIdByMonth );
            }
        }
    }
    public void getMonthlyBreakDownViaMonthlyCommission(Set<id> monthlyCommissions){
        for(monthly_break_down__c beakDowm :MonthlyBreakDownSelector.getMonthlyBreakDownViaMonthlyCommission(monthlyCommissions).values());{
            if(beakDowm.opportunity__c != null)
            {
                if(this.monthlyBreakDownsByOpportunity.containsKey(beakDowm.opportunity__c))
                {
                    this.monthlyBreakDownsByOpportunity.put(beakDowm.opportunity__c , this.monthlyBreakDownsByOpportunity.get(beakDowm.opportunity__c).add(beakDowm));
                }
                else {
                    this.monthlyBreakDownsByOpportunity.put(beakDowm.opportunity__c ,  new list<monthly_breakdown__c>{beakDowm});
                }
                
            }
            else
            {
                if(this.monthlyBreakDownsByAccount.containsKey(beakDowm.Account__c))
                {
                    this.monthlyBreakDownsByAccount.put(beakDowm.Account__c , this.monthlyBreakDownsByAccount.get(beakDowm.Account__c).add(beakDowm));
                }
                else {
                    this.monthlyBreakDownsByAccount.put(beakDowm.Account__c ,  new list<monthly_breakdown__c>{beakDowm});
                }
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
        if(invoiceDetail.opportunity__c == NULL)
        {
            preEvaluatedInvoice.accountId = invoiceDetail.Account__c;
        }
        else
        {
            preEvaluatedInvoice.opportunity__c = invoiceDetail.Opportunity__c;
            if(preEvaluatedInvoice.accountId != NULL)
            {
                preEvaluatedInvoice.accountId = invoiceDetail.Account__c;
            }
        }
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
                    this.splitsByOpportunityIdByProfileName.get(split.SplitOwner.Profile.Name).get(split.opportunityId).add(New SplitDetails(split.SplitOwnerId,split.SplitOwner.Profile.Name,0,split.SplitPercentage));   
                }
                else {
                    this.splitsByOpportunityIdByProfileName.get(split.SplitOwner.Profile.Name)
                        .put(split.opportunityId ,New List<SplitDetails>{new SplitDetails(split.SplitOwnerId,split.SplitOwner.Profile.Name,0,split.SplitPercentage)});   
                }
            }
            else {
                this.splitsByOpportunityIdByProfileName.put(split.SplitOwner.Profile.Name ,
                                                            new map<id,list<SplitDetails>>{split.OpportunityId => 
                                                                New List<SplitDetails>{New SplitDetails(split.SplitOwnerId,split.SplitOwner.Profile.Name,0,split.SplitPercentage)}});
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
                    this.splitsByOpportunityIdByProfileName.get(opportunity.owner.profile.Name).get(opportunity.id).add(New SplitDetails(opportunity.OwnerId,opportunity.owner.profile.name,0,CommissionCalculatorConstants.MARGINPERCENTFOROPPWITHNOSPLITS));   
                } 
                else{
                    this.splitsByOpportunityIdByProfileName.get(opportunity.owner.profile.Name)
                        .put(opportunity.id ,New List<SplitDetails> {new SplitDetails(opportunity.OwnerId,opportunity.owner.profile.name ,0,CommissionCalculatorConstants.MARGINPERCENTFOROPPWITHNOSPLITS)});   
                }
            }
            else {
                this.splitsByOpportunityIdByProfileName
                    .put(opportunity.owner.profile.Name ,new map<id,list<SplitDetails>>{opportunity.id => New List<SplitDetails>{New SplitDetails(opportunity.OwnerId,opportunity.owner.profile.name,0,CommissionCalculatorConstants.MARGINPERCENTFOROPPWITHNOSPLITS)}});
            }
        }
        System.debug('Exit:updateSplitsByOpportunityIdByProfileNameWithRemainingOpportunities');
    }
    
    public void updateSplitsByAccountIdByProfileName(){
        System.debug('Entring:updateSplitsByAccountIdByProfileName');
        for(Account account : AccountSelector.getAccountById(this.accountIds)){
            if(this.splitsByAccountIdByProfileName.containsKey(account.Owner.Profile.Name)){
                if(this.splitsByAccountIdByProfileName.get(account.Owner.Profile.Name).containsKey(account.id)){
                    this.splitsByAccountIdByProfileName.get(account.Owner.Profile.Name).get(account.id).add(New SplitDetails(account.OwnerId,account.Owner.Profile.Name,0,CommissionCalculatorConstants.MARGINPERCENTFORACCOUNTS));   
                } 
                else{
                    this.splitsByAccountIdByProfileName.get(account.Owner.Profile.Name)
                        .put(account.id ,New  List<SplitDetails> {new SplitDetails(account.OwnerId,account.Owner.Profile.Name ,0,CommissionCalculatorConstants.MARGINPERCENTFORACCOUNTS)});   
                }
            }
            else {
                this.splitsByAccountIdByProfileName.put(account.Owner.Profile.Name ,new map<id,list<SplitDetails>>{account.id => New List<SplitDetails>{New SplitDetails(account.OwnerId,account.Owner.Profile.Name,0,CommissionCalculatorConstants.MARGINPERCENTFORACCOUNTS)}});
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
    
    public class InvoiceMargins {
        public Decimal totalSales;
        public Decimal tileSales;
        public Decimal ancillarySales;
        public Decimal tileMargin;
        public Decimal ancillaryMargin;
        public Decimal tileMarginPercentage;
        public Decimal ancillaryMarginPercentage;
        public Decimal totalMargin;
        
        
        public invoiceMargins(){
            totalSales = 0 ;
            tileSales = 0;
            ancillarySales = 0;
            tileMargin = 0;
            ancillaryMargin = 0;
            tileMarginPercentage = 0;
            ancillaryMarginPercentage = 0;
            totalMargin = 0;
        }
        
        public invoiceMargins(Decimal totalSales, Decimal tileSales, Decimal ancillarySales, Decimal tileMargin,
                              Decimal ancillaryMargin, Decimal tileMarginPercentage, Decimal ancillaryMarginPercentage,
                              Decimal totalMargin){
                                  this.totalSales =totalSales;
                                  this.tileSales =tileSales;
                                  this.ancillarySales =ancillarySales;
                                  this.tileMargin =tileMargin;
                                  this.ancillaryMargin =ancillaryMargin;
                                  this.tileMarginPercentage =tileMarginPercentage;
                                  this.ancillaryMarginPercentage =ancillaryMarginPercentage;
                                  this.totalMargin = totalMargin;                              
                              }
    }
    Public class SplitDetails{
        Public Id ownerId;
        Public String ownerProfile;
        Public Decimal split;
        Public Decimal payableAmount;
        Public SplitDetails(Id ownerId,String ownerProfile,Decimal split , Decimal payableAmount){
            this.ownerId = ownerId;
            this.ownerProfile = ownerProfile;
            this.split = split;
            this.payableAmount = payableAmount;
        }
    }
}