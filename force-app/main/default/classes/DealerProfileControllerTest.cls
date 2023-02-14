@isTest
public class DealerProfileControllerTest {
    @testSetup static void setup(){
        Id recId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = recId;
        acc.Name = 'Test';
        acc.Phone = '9911255555';
        acc.Fax = '12231231231';
        insert acc;
        
        
        
        
        Sales_And_Market__c dealerProfileSalesAndMarket = new Sales_And_Market__c();
        dealerProfileSalesAndMarket.Account__c = acc.Id;
        dealerProfileSalesAndMarket.Total_Annual_Revenue__c = 234;
        dealerProfileSalesAndMarket.Created_year__c = '2023';
        dealerProfileSalesAndMarket.LTD_Ancillary_Sales_Market_Share__c = 33;
        dealerProfileSalesAndMarket.Annual_Tile_Ancillary_Purchases_Per__c = 40;
        dealerProfileSalesAndMarket.Annual_Tile_Sales_Percentage__c = 45;
        dealerProfileSalesAndMarket.Assumed_Annual_Purchases_Percentage__c = 25;
        dealerProfileSalesAndMarket.LTD_Ancillary_Sales_Market_Share__c = 29;
        dealerProfileSalesAndMarket.ltd_Ancillary_Sales_MST__c = 35;
        dealerProfileSalesAndMarket.LTD_Ancillary_Sales_Percentage__c = 45;
        dealerProfileSalesAndMarket.LTD_Tile_Ancillary_Sales_Market_Share__c = 40;
        dealerProfileSalesAndMarket.LTD_Tile_Ancillary_Sales_Percentage__c = 35;
        dealerProfileSalesAndMarket.ltd_Tile_And_Ancillary_Sales_MST__c = 45;
        dealerProfileSalesAndMarket.ltd_Tile_Sales_Market_MST__c = 54;
        dealerProfileSalesAndMarket.LTD_Tile_Sales_Market_Share__c = 43;
        dealerProfileSalesAndMarket.LTD_Tile_Sales_Percentage__c = 32;
        dealerProfileSalesAndMarket.Tile_Purchases_Percentage__c = 33;
        dealerProfileSalesAndMarket.Total_Annual_Revenue_Percentage__c = 65;
        dealerProfileSalesAndMarket.Ancillary_Purchases_Percentage__c = 25;
        Insert dealerProfileSalesAndMarket;
        
        Dealer_Customer__c dcustomer=new Dealer_Customer__c();
        dcustomer.Customer_Name__c='Test';
        dcustomer.Account__c=acc.Id;
        dcustomer.Sales_And_Market__c=dealerProfileSalesAndMarket.Id;
        insert dcustomer;
        
        Display_Item__c displayItem = new Display_Item__c();
        displayItem.Account__c =acc.id;
        displayItem.Price__c = 100;
        displayItem.Style_Type__c = 'Test supply type';
        displayItem.Supplier__c = 'Test Supplier';
        displayItem.SalesandMarket__c = dealerProfileSalesAndMarket.id;
        displayItem.Type__c = 'LVT';
        displayItem.Volume__c = 200.0;
        displayItem.Why_is_the_Dealer_using_products__c = 'TEst Why_is_the_Dealer_using_products__c';
        insert displayItem;
        
        Display_Item__c dc=new Display_Item__c();
        dc.Supplier__c='Home';
        dc.Manufacturer__c='manu';
        dc.Account__c=acc.id;
        insert dc;
        
    }
    
    @isTest static void getMetaDataRecordsTest(){
        test.startTest();
        Map<String,String> mapNalueByName = DealerProfileController.getMetaDataRecords();
        test.stopTest();
    }
    @isTest static void fetchOnLoadConfigrationTest(){
        Id AccountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        test.startTest();
        Map<String,List<String>> mapNalueByName = DealerProfileController.fetchOnLoadConfigration(AccountId);
        test.stopTest();  
    }
    @isTest static void getAccountsByIdTest(){
        Id AccountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        test.startTest();
        List<Account> listAccount = DealerProfileController.getAccountsById(AccountId);
        test.stopTest();   
    }
    @isTest static void getAllDealerProfilesTest(){
        Id AccountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        
        test.startTest();
        List<Sales_And_Market__c> listSalesAndMarket = DealerProfileController.getAllDealerProfiles(AccountId);
        test.stopTest();   
    }
    @isTest static void getDealerProfileRecordTest(){
        
        Id AccountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        Id salesId = [Select Id,Created_year__c from Sales_And_Market__c where Created_year__c = '2023' limit 1].Id;
        String selectedYear = '2023';
        Dealer_Customer__c dc=new Dealer_Customer__c();
        dc.Account__c=AccountId;
        dc.Customer_Name__c='name';
        dc.Inactive__c=true;
        dc.Customer_Type__c='Dealer';
        dc.Selections__c='Home';
        dc.Sales_And_Market__c=salesId;
        insert dc;
        test.startTest();
        DealerProfileController.getDealerProfileRecord(selectedYear,AccountId);
        test.stopTest();   
    }
    @isTest static void saveDisplayItemsTest(){
        Id AccountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        DealerProfileController.DisplayItemWrapper displayItem = new DealerProfileController.DisplayItemWrapper();
        DealerProfileController.DisplayItemByType displayItemByType = new DealerProfileController.DisplayItemByType();
        DisplayItemByType.dealerType='Ancillary Items';
        DisplayItemByType.manufacturer='Test Manufacturer';
        DisplayItemByType.price = 12.0;
        DisplayItemByType.Supplier = 'Test Supplier';
        DisplayItemByType.isChange = true;
        DisplayItemByType.isDeleted = false;
        displayItem.displayItemByTypeDetails.add(DisplayItemByType);
        
        test.startTest();
        DealerProfileController.saveDisplayItems(JSON.serialize(displayItem),AccountId);
        test.stopTest();   
    }
    @isTest static void saveDisplayItemsTest2(){
        Id AccountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        Id displayitemid = [Select Id from Display_Item__c where Manufacturer__c = 'manu' limit 1].Id;
        DealerProfileController.DisplayItemWrapper displayItem = new DealerProfileController.DisplayItemWrapper();
        DealerProfileController.DisplayItemByType displayItemByType = new DealerProfileController.DisplayItemByType();
        DisplayItemByType.dealerType='Ancillary Items';
        DisplayItemByType.manufacturer='Test Manufacturer';
        DisplayItemByType.price = 12.0;
        DisplayItemByType.ids=displayitemid;
        DisplayItemByType.Supplier = 'Test Supplier';
        DisplayItemByType.isChange = true;
        DisplayItemByType.isDeleted = false;
        displayItem.displayItemByTypeDetails.add(DisplayItemByType);
        
        test.startTest();
        DealerProfileController.saveDisplayItems(JSON.serialize(displayItem),AccountId);
        test.stopTest();   
    }
    
    
    @isTest static void getDisplayItemTest(){
        Id accountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        string displayItemType = 'LVT';
        string currentYear = '2022';
        test.startTest();
        DealerProfileController.getDisplayItem(displayItemType,currentYear,accountId);
        test.stopTest();
    }
    
    @isTest static void getAccountDetailsTest(){
        Id accountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        test.startTest();
        DealerProfileController.getAccountDetails(accountId);
        test.stopTest();
    }
    
    @isTest static void getRecordByYearTest(){
        Id accountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        string selectedYear = [Select Id,Account__c,Created_year__c from Sales_And_Market__c where Account__c = :accountId limit 1].Created_year__c;
        test.startTest();
        integer salesAndMarketCount = DealerProfileController.getRecordByYear(selectedYear,accountId);
        test.stopTest();
        system.assertEquals(1, salesAndMarketCount);
    }
    @istest
    public static void saveDealerProfileRecordTest(){
        Id AccountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
        Id dealerCustomerId = [Select Id,Name from Dealer_Customer__c where Customer_Name__c = 'Test' limit 1].Id;
        DealerProfileController.DealerProfileWrapper objdealerProfileWrapper =new DealerProfileController.DealerProfileWrapper();
        objdealerProfileWrapper.dealerName='Test';
        objdealerProfileWrapper.ltdAncillarySalesMarketShareTarget=100;
        objdealerProfileWrapper.ltdTileSalesMarketShareTarget=100;
        objdealerProfileWrapper.ltdTileAndAncillarySalesMarketShareTarget=100;
        objdealerProfileWrapper.dealerAnnualSalesTotal=100;
        objdealerProfileWrapper.createdYear='2022';
        objdealerProfileWrapper.dealerAnnualSalesTotalPercentage=100;
        objdealerProfileWrapper.dealerAnnualPurchase=100;
        objdealerProfileWrapper.dealerAnnualPurchasePercentage=100;
        objdealerProfileWrapper.dealerAnnualTileSaleincludelabour=100;
        objdealerProfileWrapper.dealerAnnualTileSaleincludelabourPercentage=100;
        objdealerProfileWrapper.dealerAnnualPurchase=100;
        objdealerProfileWrapper.ancillaryPurchases=100;
        objdealerProfileWrapper.ancillaryPurchasesPercentage=100;
        objdealerProfileWrapper.dealerAnnualTileandAnnualPurchase=100;	
        objdealerProfileWrapper.dealerAnnualTileandAnnualPurchasePercentage=100;
        objdealerProfileWrapper.tilePurchase=100;
        objdealerProfileWrapper.tilePurchasePercentage=100;
        objdealerProfileWrapper.ltdTileAndAncillarySales=100;
        objdealerProfileWrapper.ltdTileAndAncillarySalesPercentage=100;
        objdealerProfileWrapper.ltdTileSale=100;
        objdealerProfileWrapper.ltdTileSalePercentage=100;
        objdealerProfileWrapper.ltdAncillarySales=100;
        objdealerProfileWrapper.ltdAncillarySalesPercentage=100;
        objdealerProfileWrapper.ltdTileAndAncillarySalesMarketShare=100;
        objdealerProfileWrapper.ltdTileSalesMarketShare=100;
        objdealerProfileWrapper.ltdAncillarySalesMarketShare=100;  
        List <DealerProfileController.DealerCustomerDetailsWrapper> dcd=new List<DealerProfileController.DealerCustomerDetailsWrapper>();
        for(Integer i=1;i<10;i++){
            DealerProfileController.DealerCustomerDetailsWrapper dcWrap=new DealerProfileController.DealerCustomerDetailsWrapper();
            dcWrap.customerName='customerName'+i;
            dcWrap.customerType='Dealer';
            dcWrap.salesperson='salesperson';
            dcWrap.supplier='supplier';
            dcWrap.inactive=true;
            dcWrap.dealerCustomerId=dealerCustomerId;
            dcd.add(dcWrap);
            
        }
        objdealerProfileWrapper.dealerCustomerDetails=dcd;    
        test.startTest();
        DealerProfileController.saveDealerProfileRecord(JSON.serialize(objdealerProfileWrapper),AccountId);
        test.stopTest();
        
    }
    
    /*  @istest
public static void saveDealerProfileRecordTest2(){
Id AccountId = [Select Id,Name from Account where Name = 'Test' limit 1].Id;
Sales_And_Market__c salesId = [Select id from Sales_And_Market__c where Created_year__c = '2023' limit 1];
DealerProfileController.DealerProfileWrapper  dealerProfile=new DealerProfileController.DealerProfileWrapper();
DealerProfileController.DealerCustomerDetailsWrapper dealerCustomer=new DealerProfileController.DealerCustomerDetailsWrapper();

dealerProfile.dealerAnnualSalesTotal=100;
dealerProfile.ltdTileSale=109;


dealerProfile.ltdAncillarySales=343;
test.startTest();
DealerProfileController.saveDealerProfileRecord(JSON.serialize(salesId),AccountId);
test.stopTest();

}*/
    
    
}