trigger invoiceDetailTrigger on Invoice_Detail__c (after insert) {
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            invoiceDetailTriggerHandler.invoiceDetailTriggerHelper(trigger.newmap);
        }
    }

}