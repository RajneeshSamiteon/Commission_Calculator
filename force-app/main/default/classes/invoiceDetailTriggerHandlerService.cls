public class invoiceDetailTriggerHandlerService {
    
    /***********************************************************
	This method is for calculating requried tile and 
	ancillary margins and margin percentage for all profiles.
	************************************************************/
    public static InvoiceMargins invoiceMarginCalculations(invoiceMargins preEvaluatedInvoice , Invoice_Detail__c invoiceDetail)
    {	
        try{
            preEvaluatedInvoice.totalSales += invoiceDetail.Item_Price__c;
            if(invoiceDetail.Item_Group__c == commissionCalculatorconstants.itemGroupTile)
            {
                preEvaluatedInvoice.tileSales += invoiceDetail.Item_Price__c;
                preEvaluatedInvoice.tileMargin += (invoiceDetail.Item_Price__c - invoiceDetail.Item_cost__c);
                preEvaluatedInvoice.tileMarginPercentage = (preEvaluatedInvoice.tileMargin /preEvaluatedInvoice.tileSales) *100;
            }
            else
            {
                preEvaluatedInvoice.AncillarySales += invoiceDetail.Item_Price__c;
                preEvaluatedInvoice.AncillaryMargin += (invoiceDetail.Item_Price__c - invoiceDetail.Item_cost__c);
                preEvaluatedInvoice.ancillaryMarginPercentage += (preEvaluatedInvoice.AncillaryMargin / preEvaluatedInvoice.AncillarySales) *100;
            }
            return preEvaluatedInvoice;
        }
        catch(exception e){
            ExceptionUtils.createExceptionLogV2('invoiceDetailTriggerHandlerService',e.getMessage(),e.getStackTraceString());
            return null;
        }
    }
    
}