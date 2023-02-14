public class invoiceDetailTriggerHandler {
    /***************************************************
		=> This is our master method from where we'll 
		   be segregating our data and passing them 
		   to different methods.

        => EvaluatedInvoicesByOpportunity map stores 
			all the sagregated invoice commission bases 
			on opportunity owner

        => EvaluatedInvoicesByAccount map stores all 
			the sagregated invoice commission bases on 
			account owner
	****************************************************/
    public static void invoiceDetailTriggerHelper(map<id,invoice_detail__c> Invoices)
    {
        map<id,invoiceMargins> evaluatedInvoicesByOpportunity = new map<id,invoiceMargins>();
        map<id,invoiceMargins> evaluatedInvoicesByAccount = new map<id,invoiceMargins>();
        double totalSales =0;
        double tileSales =0;
        double AncillarySales =0;
        double tileMargin =0;
        double AncillaryMargin =0;
        double tileMarginPercentage =0;
        double ancillaryMarginPercentage =0;
        for(invoice_detail__c  invoiceDetail : Invoices.values())
        {
            if(invoicedetail.Opportunity__c != null){
                
                if(evaluatedInvoicesByOpportunity.containsKey(invoiceDetail.Opportunity__c))
                {
                    evaluatedInvoicesByOpportunity.put(invoiceDetail.Opportunity__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(evaluatedInvoicesByOpportunity.get(invoiceDetail.Opportunity__c),invoiceDetail));
                }
                else{
                    InvoiceMargins preEvaluatedInvoice = new InvoiceMargins(totalSales,
                                                                            tileSales,
                                                                            AncillarySales,
                                                                            tileMargin,
                                                                            AncillaryMargin,
                                                                            tileMarginPercentage,
                                                                            ancillaryMarginPercentage);
                    evaluatedInvoicesByOpportunity.put(invoiceDetail.Opportunity__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(preEvaluatedInvoice,invoiceDetail));
                }
            }
            else{
                 if(evaluatedInvoicesByAccount.containsKey(invoiceDetail.Account__c))
                {
                    evaluatedInvoicesByAccount.put(invoiceDetail.Account__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(evaluatedInvoicesByAccount.get(invoiceDetail.Account__c),invoiceDetail));
                }
                else
                {
                    InvoiceMargins preEvaluatedInvoice =  new InvoiceMargins(totalSales,
                                                                            tileSales,
                                                                            AncillarySales,
                                                                            tileMargin,
                                                                            AncillaryMargin,
                                                                            tileMarginPercentage,
                                                                            ancillaryMarginPercentage);
                    evaluatedInvoicesByAccount.put(invoiceDetail.Account__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(preEvaluatedInvoice,invoiceDetail));
                }
            }
        }
    }
}