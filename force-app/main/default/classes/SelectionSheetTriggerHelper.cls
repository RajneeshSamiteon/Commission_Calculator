public class SelectionSheetTriggerHelper {
    
    public static void isbeforeInsert(List<Selection_Sheet__c> selectionSheet_lineItems){
            getselectionSheetLineItems(selectionSheet_lineItems);
    }
    
    public static void updateSelectionSheetStatus(List<Selection_Sheet__c> selectionSheet_lineItems){
       
        for(Selection_Sheet__c sheet:selectionSheet_lineItems){
            if((sheet.Status__c).trim()=='Inquiry - Planning'){
                sheet.Status__c='Inquiry/Planning';
            }else if((sheet.Status__c).trim()=='On Order'){
                sheet.Status__c='Order';
            }else if((sheet.Status__c).trim()=='Completed'){
                sheet.Status__c='Sold';
            }else if((sheet.Status__c).trim()=='Partial Order'){
                sheet.Status__c='Order';
            }
        }
        
    }
    
    public static void selectionSheetsAfterInsert(List<Selection_Sheet__c> sheets){
        set<Id> opportunityIds=new set<Id>();
        Map<Id,opportunityLineItem> mapOfProductIdAndopportunityLineItem=new Map<Id,opportunityLineItem>();
        Map<Id,Selection_Sheet__c> mapOfProductIdAndSelectionSheet=new Map<Id,Selection_Sheet__c>();
        Map<Id,set<String>> mapOfOpportunityIdAndSelectionSheetStatus=new Map<Id,set<String>>();
        Map<Id,Opportunity> MapOfselectsheetsAndOpportunity=new Map<Id,Opportunity>();
        Map<Id,List<Selection_Sheet__c>> mapOfOppIdAndSSsize= new Map<Id,List<Selection_Sheet__c>>();
        Map<Id,List<opportunityLineItem>> mapOfOppIdAndOppLineitems= new Map<Id,List<opportunityLineItem>>();
        Integer selectionsheetSize=0;
        for(Selection_Sheet__c selectionsheet:sheets){
            if(selectionsheet.Status__c !=null && selectionsheet.Opportunity__c != null){
                opportunityIds.add(selectionsheet.Opportunity__c);
            }
        }
        List<opportunityLineItem> opLineItems=opportunityLineItemSelector.getOpportunityLineItemByIds(opportunityIds);
        //System.debug('opLineItems-----'+opLineItems);
        for(opportunityLineItem opLine:opLineItems){
            if(opLine.Product2Id!=null){
                mapOfProductIdAndopportunityLineItem.put(opLine.Product2Id,opLine);
            }
            if(opLine.OpportunityId!=null){
                mapOfProductIdAndopportunityLineItem.put(opLine.Product2Id,opLine);
                
                if(mapOfOppIdAndOppLineitems.containskey(opLine.OpportunityId)){
                    List<opportunityLineItem> olne=mapOfOppIdAndOppLineitems.get(opLine.OpportunityId);
                    olne.add(opLine);
                }else{
                    mapOfOppIdAndOppLineitems.put(opLine.OpportunityId,new List<opportunityLineItem>{opLine});
                }
            }
        }
        //System.debug('mapOfProductIdAndopportunityLineItem----'+mapOfProductIdAndopportunityLineItem);
        List<Selection_Sheet__c> selectionSheets=SelectionSheetSelector.getSelectionSheetByOpportunityIds(opportunityIds);
        //System.debug('selectionSheets------'+selectionSheets);
        for(Selection_Sheet__c sheet:selectionSheets){
            if(sheet.Product__c!=null){
                mapOfProductIdAndSelectionSheet.put(sheet.Product__c,sheet);
            }
        }
        //System.debug('mapOfProductIdAndSelectionSheet-----'+mapOfProductIdAndSelectionSheet);
        for(Id prodId:mapOfProductIdAndopportunityLineItem.keyset()){
            if(mapOfProductIdAndSelectionSheet.containsKey(prodId)){
                
                //System.debug('mapOfProductIdAndSelectionSheet.containsKey(prodId)===='+mapOfProductIdAndSelectionSheet.containsKey(prodId));
                if(mapOfOpportunityIdAndSelectionSheetStatus.containskey(mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c)){
                    //System.debug('mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c----'+mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c);
                    set<String> sheetStatus=mapOfOpportunityIdAndSelectionSheetStatus.get(mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c);
                    sheetStatus.add(mapOfProductIdAndSelectionSheet.get(prodId).Status__c);
                    mapOfOpportunityIdAndSelectionSheetStatus.put(mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c,sheetStatus);
                }else{
                    mapOfOpportunityIdAndSelectionSheetStatus.put(mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c,new set<String> {mapOfProductIdAndSelectionSheet.get(prodId).Status__c});
                }
                
                if(mapOfOppIdAndSSsize.containskey(mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c)){
                    List<Selection_Sheet__c> olne=mapOfOppIdAndSSsize.get(mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c);
                    olne.add(mapOfProductIdAndSelectionSheet.get(prodId));
                }else{
                    mapOfOppIdAndSSsize.put(mapOfProductIdAndSelectionSheet.get(prodId).Opportunity__c,new List<Selection_Sheet__c>{mapOfProductIdAndSelectionSheet.get(prodId)});
                }
            }
        }
        
        for(Id opId:mapOfOpportunityIdAndSelectionSheetStatus.keyset()){
            //System.debug('value of map---'+mapOfOpportunityIdAndSelectionSheetStatus.get(opId));
            //System.debug('mapofIdAndSelectionsheet-selectsheet121----'+(String.valueOf(mapOfOpportunityIdAndSelectionSheetStatus.get(opId)));
            //System.debug('mapOfOppIdAndOppLineitems.get(opId).size()-----'+mapOfOppIdAndOppLineitems.get(opId).size());
            if(mapOfOppIdAndOppLineitems.containsKey(opId) && mapOfOppIdAndSSsize.containsKey(opId) && mapOfOppIdAndSSsize.get(opId).size() == mapOfOppIdAndOppLineitems.get(opId).size()){
                //System.debug('mapOfOppIdAndSSsize.get(opId).size()----'+mapOfOppIdAndSSsize.get(opId).size());
                
                if( mapOfOpportunityIdAndSelectionSheetStatus.get(opId).size() == 1){
                    //System.debug('sdfwerwe----'+String.valueOf(mapOfOpportunityIdAndSelectionSheetStatus.get(opId)));
                    if(mapOfOpportunityIdAndSelectionSheetStatus.get(opId).contains('Order')){
                        //System.debug('order---');
                        Opportunity opp = new Opportunity();
                        opp.Id=opId;
                        // System.debug('opp.Id---'+opp.Id);
                        opp.StageName='On Order';
                        MapOfselectsheetsAndOpportunity.put(opp.Id,opp);
                        //System.debug('MapOfselectsheetsAndOpportunity1211----'+MapOfselectsheetsAndOpportunity.values());
                    }else if(String.valueOf(mapOfOpportunityIdAndSelectionSheetStatus.get(opId))=='{Sold}'){
                        Opportunity opp = new Opportunity();
                        opp.Id=opId;
                        opp.StageName='Sold';
                        MapOfselectsheetsAndOpportunity.put(opp.Id,opp);
                        //System.debug('MapOfselectsheetsAndOpportunity1212----'+MapOfselectsheetsAndOpportunity.values());
                        
                    }else if(mapOfOpportunityIdAndSelectionSheetStatus.get(opId).contains('Inquiry/Planning')){
                        Opportunity opp = new Opportunity();
                        opp.Id=opId;
                        opp.StageName='Inquiry/Planning';
                        MapOfselectsheetsAndOpportunity.put(opp.Id,opp);
                        //System.debug('MapOfselectsheetsAndOpportunity1213----'+MapOfselectsheetsAndOpportunity.values());
                    }
                }
                else if(mapOfOpportunityIdAndSelectionSheetStatus.get(opId).size()==2 && (mapOfOpportunityIdAndSelectionSheetStatus.get(opId).contains('Order') && mapOfOpportunityIdAndSelectionSheetStatus.get(opId).contains('Sold'))){
                    
                    
                    Opportunity opp = new Opportunity();
                    opp.Id=opId;
                    opp.StageName='On Order';
                    MapOfselectsheetsAndOpportunity.put(opp.Id,opp);
                    //System.debug('MapOfselectsheetsAndOpportunity121----'+MapOfselectsheetsAndOpportunity.values());
                    
                }else if(mapOfOpportunityIdAndSelectionSheetStatus.get(opId).size()==2 && mapOfOpportunityIdAndSelectionSheetStatus.get(opId).contains('Inquiry/Planning')){
                    Opportunity opp = new Opportunity();
                    opp.Id=opId;
                    opp.StageName='Partial Order';
                    MapOfselectsheetsAndOpportunity.put(opp.Id,opp);
                    //System.debug('MapOfselectsheetsAndOpportunity121----'+MapOfselectsheetsAndOpportunity.values());
                }
                else if(mapOfOpportunityIdAndSelectionSheetStatus.get(opId).size()==3){
                    Opportunity opp = new Opportunity();
                    opp.Id=opId;
                    opp.StageName='Partial Order';
                    MapOfselectsheetsAndOpportunity.put(opp.Id,opp);
                    //System.debug('MapOfselectsheetsAndOpportunity121----'+MapOfselectsheetsAndOpportunity.values());
                }
            }else{
                Opportunity opp = new Opportunity();
                opp.Id=opId;
                opp.StageName='Partial Order';
                MapOfselectsheetsAndOpportunity.put(opp.Id,opp);
                //System.debug('MapOfselectsheetsAndOpportunity-----'+MapOfselectsheetsAndOpportunity.values());
            }
        }
        
            update MapOfselectsheetsAndOpportunity.values(); 
        
        //System.debug('MapOfselectsheetsAndOpportunity121----'+MapOfselectsheetsAndOpportunity.values());
    }  
    
    public static void getselectionSheetLineItems(List<Selection_Sheet__c> selectionSheet_lineItems){
        //system.debug('K_lineItems----'+selectionSheet_lineItems);
        List<String> selectionSheetLineItemProductName= new List<String>();
        List<Selection_Sheet__c> K_orderItem=new List<Selection_Sheet__c>();
        Map<String,Id> mapOFIdAndProduct=new Map<String,Id>();
        for(Selection_Sheet__c items:selectionSheet_lineItems){
            if(items.Product_name__c!=null){
                selectionSheetLineItemProductName.add(items.Product_name__c); 
            }
        }
        //System.debug('selectionSheetLineItemProductName----'+selectionSheetLineItemProductName);
        List<Product2> products = ProductSelector.fetchProducts(selectionSheetLineItemProductName);
        for(Product2 prod:products){
            mapOFIdAndProduct.put(prod.Name,prod.id);
        }
        //System.debug('mapOFIdAndProduct-----'+mapOFIdAndProduct.values());
        for(Selection_Sheet__c items:selectionSheet_lineItems){
            if(mapOFIdAndProduct.containsKey(items.Product_name__c)){
                items.Product__c= mapOFIdAndProduct.get(items.Product_name__c);
            }       
        }
    }
    
    
    public static void productInsertInOpportunityLineItem(List<Selection_Sheet__c> selectionSheets){
        List<OpportunityLineItem> opportunityLineItemsToBeInsert=new List<OpportunityLineItem>();
        List<PricebookEntry> priceBooks=new List<PricebookEntry>();
        List<Selection_Sheet__c> selectionSheetsforInsert=new List<Selection_Sheet__c>();
        Map<Id,Selection_Sheet__c> MapOfListOfSelectionSheetByProductId=new Map<Id,Selection_Sheet__c>();
        Map<Id,Id> mapOfPricebookIdByOppId=new Map<Id,Id>();
        Map<Id,List<PricebookEntry>> mapOfPricebooksByOppId=new Map<Id,List<PricebookEntry>>();
        Map<Id,PricebookEntry> mapOfPricebookByProductIdct=new Map<Id,PricebookEntry>();
        Id recordTypeId =RecordTypeSelector.getIdByDeveloperNameAndObjectType('Retail_Opportunities','Opportunity');
        
        Set<Id> productIds=new Set<Id>();
        List<PricebookEntry> customPriceBookEntry=new List<PricebookEntry>();
        set<Id> OppIds=new set<Id>();
        for(Selection_Sheet__c sheet:selectionSheets){
            if(sheet.Product__c !=null){
                //System.debug('sheet.Opportunity__r.RecordTypeId------'+sheet.Opportunity__r.RecordTypeId);
                MapOfListOfSelectionSheetByProductId.put(Id.valueOf(sheet.Product__c),sheet);
                OppIds.add(sheet.Opportunity__c);
            }
        }
        
        Map<Id,Opportunity> mapOfOpportunityBYId= new Map<Id,Opportunity>(OpportunitySelector.getOpportunitiesByIdsAndRecordId(OppIds,recordTypeId));
        
        List<PricebookEntry> priceBooksForcheckStatnderPrice=PriceBookEntrySelector.getPriceBooksByProductIdAndPricebookId(MapOfListOfSelectionSheetByProductId.keySet());
        //System.debug('priceBooksForcheckStatnderPrice----'+priceBooksForcheckStatnderPrice);
        for(PricebookEntry pb:priceBooksForcheckStatnderPrice){
            mapOfPricebookByProductIdct.put(pb.Product2Id,pb);
        }
        for(PricebookEntry pBook:mapOfPricebookByProductIdct.values()){
            if(MapOfListOfSelectionSheetByProductId.containsKey(pBook.Product2Id) && 
               mapOfOpportunityBYId.containsKey(MapOfListOfSelectionSheetByProductId.get(pBook.Product2Id).Opportunity__c) &&
               String.isNotBlank(MapOfListOfSelectionSheetByProductId.get(pBook.Product2Id).Quantity__c) &&
               decimal.valueof(MapOfListOfSelectionSheetByProductId.get(pBook.Product2Id).Quantity__c)>0 && mapOfOpportunityBYId.get(MapOfListOfSelectionSheetByProductId.get(pBook.Product2Id).Opportunity__c).Pricebook2Id ==  pBook.Pricebook2.Id){
                   OpportunityLineItem opLineItem=new OpportunityLineItem();
                   opLineItem.OpportunityId=MapOfListOfSelectionSheetByProductId.get(pBook.Product2Id).Opportunity__c;
                   opLineItem.Product2Id=pBook.Product2Id;
                   opLineItem.Quantity= decimal.valueof(MapOfListOfSelectionSheetByProductId.get(pBook.Product2Id).Quantity__c);
                   opLineItem.UnitPrice=pBook.UnitPrice;
                   opLineItem.PricebookEntryId=pBook.Id;
                   opportunityLineItemsToBeInsert.add(opLineItem);
                   Selection_Sheet__c ss=new Selection_Sheet__c();
                   ss.Id=MapOfListOfSelectionSheetByProductId.get(pBook.Product2Id).Id;
                   ss.Product_Added__c=true;
                   selectionSheetsforInsert.add(ss);
               }
            
        }
        
        if(!opportunityLineItemsToBeInsert.isEmpty()){
            insert opportunityLineItemsToBeInsert;
        }
        if(!selectionSheetsforInsert.isEmpty()){
            update selectionSheetsforInsert;
        }
    }
    public static void productUpdateInOpportunityLineItem(Map<Id,Selection_Sheet__c> selectionSheetbyId,Map<Id,Selection_Sheet__c> oldSelectionSheetById){
        List<OpportunityLineItem> opportunityLineItemsToBeUpdate=new List<OpportunityLineItem>();
        set<String> setOfUniqueKeys=new set<String>();
                Map<Id,PricebookEntry> mapOfPricebookByProductIdct=new Map<Id,PricebookEntry>();

        Map<Id,OpportunityLineItem> OpportunityLineItemByProductId=new Map<Id,OpportunityLineItem>();
        Map<Id,Selection_Sheet__c> SelectionSheetByProductIdwithUniqueKey=new Map<Id,Selection_Sheet__c>();
        Map<Id,Selection_Sheet__c> MapOfListOfSelectionSheetByProductId=new Map<Id,Selection_Sheet__c>(); 
        set<Id> OppIds=new set<Id>();
        Id recordTypeId =RecordTypeSelector.getIdByDeveloperNameAndObjectType('Retail_Opportunities','Opportunity');
        for(Selection_Sheet__c sheet:selectionSheetbyId.values()){
            if(sheet.Product__c !=null && sheet.Quantity__c !=oldSelectionSheetById.get(sheet.id).Quantity__c){
                setOfUniqueKeys.add(sheet.unique_key_selection__c);
                MapOfListOfSelectionSheetByProductId.put(sheet.Product__c,sheet);
                OppIds.add(sheet.Opportunity__c);
            }
        }
        /*List<Selection_Sheet__c> selectionSheetByUniqueKey=[SELECT id,Name,unique_key_selection__c,Selection_Sheet_ID__c,
                                                            SS_Line_Number__c,
                                                            Product__c from Selection_Sheet__c where unique_key_selection__c IN:setOfUniqueKeys];*/
        for(Selection_Sheet__c sheet:SelectionSheetSelector.getselectionSheetByUniqueKey(setOfUniqueKeys)){
            if(sheet.Product__c !=null){
                SelectionSheetByProductIdwithUniqueKey.put(sheet.Product__c,sheet);
            }
        }
         List<OpportunityLineItem> opportunityLineItemsToBeInsert=new List<OpportunityLineItem>();
        Map<Id,Opportunity> mapOfOpportunityBYId= new Map<Id,Opportunity>(OpportunitySelector.getOpportunitiesByIdsAndRecordId(OppIds,recordTypeId));
       /*List<OpportunityLineItem> opLineItems = [SELECT id,Product2Id,Quantity from OpportunityLineItem where OpportunityId=:mapOfOpportunityBYId.keyset()];*/
        for(OpportunityLineItem opLine:opportunityLineItemSelector.getOppLineItemByOpId(mapOfOpportunityBYId)){
            OpportunityLineItemByProductId.put(opLine.Product2Id,opLine);
        } 
        List<PricebookEntry> priceBooksForcheckStatnderPrice=PriceBookEntrySelector.getPriceBooksByProductIdAndPricebookId(MapOfListOfSelectionSheetByProductId.keySet());
        //System.debug('priceBooksForcheckStatnderPrice----'+priceBooksForcheckStatnderPrice);
        for(PricebookEntry pb:priceBooksForcheckStatnderPrice){
            mapOfPricebookByProductIdct.put(pb.Product2Id,pb);
        }
        for(Selection_Sheet__c sheet:SelectionSheetByProductIdwithUniqueKey.values()){
            if(selectionSheetbyId.containsKey(sheet.Id) 
               &&  selectionSheetbyId.get(sheet.Id).unique_key_selection__c !=null && 
               selectionSheetbyId.get(sheet.Id).unique_key_selection__c == sheet.unique_key_selection__c 
               && OpportunityLineItemByProductId !=null && OpportunityLineItemByProductId.containsKey(sheet.Product__c)&& mapOfPricebookByProductIdct.containsKey(sheet.Product__c)) 
                
            {
                 OpportunityLineItem opLineItem=new OpportunityLineItem();
                 opLineItem.Id=OpportunityLineItemByProductId.get(sheet.Product__c).id;
                 opLineItem.Quantity = decimal.valueof(selectionSheetbyId.get(sheet.Id).Quantity__c);
              opLineItem.TotalPrice=decimal.valueof(selectionSheetbyId.get(sheet.Id).Quantity__c)*mapOfPricebookByProductIdct.get(sheet.Product__c).UnitPrice;
                opportunityLineItemsToBeUpdate.add(opLineItem);
            }
        }
        if(!opportunityLineItemsToBeUpdate.isEmpty()){
            update opportunityLineItemsToBeUpdate;
        }
    }
}