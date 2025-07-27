@isTest
private class MSP_TradeHoldRequestResourceTest {
    
    private static Id finAccGeneralRecTypeId = RecordTypeUtil.getFinancialAccountRecordTypeIdByName(RecordTypeUtil.FINANCIAL_ACCOUNT_GENERAL_ACCOUNT);
    private static final String USER_ALIAS = 'Planner';
    
    // Create Test Data
    @testSetup
    private static void setup(){
        User planner = CreateTestRecordUtils.createTestUser('Field Advisor Dragonfly1', USER_ALIAS ,false);
        planner.email = 'MSP_APIClientBaseTest@fngn.com';
        planner.SSO_username__c = USER_ALIAS;
        insert planner;
        
        createData();
    }
    
    @future
    private static void createData(){
        User planner = [SELECT Id FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
        CreateTestRecordUtils.setFinServPersonAccountFlag(true);
        Account primaryAcc = new Account(FirstName = 'Primary',LastName = 'Account',Email__c='primary@test.com',Assigned_Adviser__c= planner.Id);
        insert primaryAcc;
        Id hhId = HouseholdDao.getAccidWithHHids(new List<Id>{primaryAcc.Id}).values()[0];
        FinServ__FinancialAccount__c finAcct = new FinServ__FinancialAccount__c(Name = 'Test',
                                                                                RecordTypeId = RecordTypeUtil.getFinancialAccountRecordTypeIdByName(Constant.FINANCIAL_ACCOUNT_GENERAL_ACCOUNT), 
                                                                                Estimated_Account_Value__c = 50000,
                                                                                FinServ__FinancialAccountNumber__c = '72727272',
                                                                                FinServ__PrimaryOwner__c = primaryAcc.Id,
                                                                                Custodian__c = Constant.CUSTODIAN_CHARLES_SCHWAB,
                                                                                FinServ__Household__c = hhId);
        insert finAcct;
    }
    
    @isTest
    static void testSendTradeHoldRequest() {
        
        Account primaryAcc = [SELECT Id FROM Account limit 1];
        Id hhId = HouseholdDao.getAccidWithHHids(new List<Id>{primaryAcc.Id}).values()[0];
        FinServ__FinancialAccount__c finAcc = [SELECT Id, Custodian__c, FinServ__FinancialAccountNumber__c, Formatted_Account_Number__c FROM 
                                              	FinServ__FinancialAccount__c limit 1];
        
        // Create a test instance of MSP_TradeHoldRequestResource
        MSP_TradeHoldRequestResource resTradeHoldStatus = new MSP_TradeHoldRequestResource(hhId)
            .setAccountId(finAcc.Id)
            .setAccountNumber(finAcc.FinServ__FinancialAccountNumber__c)
            .setCustodian('SCHWABINST')
            .setTradeHoldNote('reasonNotes')
            .setTradeHold(true);
        
        Test.startTest();
        
        // Mock the HTTP callout response
        HttpCalloutMock mock = new MSP_TradeHoldMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method to be tested
        HttpCalloutBuilder.HttpCalloutResponse response = resTradeHoldStatus.sendTradeHoldRequest();
        Test.stopTest();
		
        MSP_TradeHoldRequestResource.MSP_PutTradeHoldResponseResource tradeHoldResponse = (MSP_TradeHoldRequestResource.MSP_PutTradeHoldResponseResource) response.parsedResponse;
        //Assert that trade hold response is true. 
        Assert.areEqual(tradeHoldResponse.isTradeHold, true, 'Trade hold is set as true');
    }
    
    @isTest
    static void testGetTradeHold() {
        
        Account primaryAcc = [SELECT Id FROM Account limit 1];
        Id hhId = HouseholdDao.getAccidWithHHids(new List<Id>{primaryAcc.Id}).values()[0];
        FinServ__FinancialAccount__c finAcc = [SELECT Id, Custodian__c, FinServ__FinancialAccountNumber__c, Formatted_Account_Number__c FROM 
                                              	FinServ__FinancialAccount__c limit 1];
        
        // Create a test instance of MSP_TradeHoldRequestResource
        MSP_TradeHoldRequestResource resTradeHoldStatus = new MSP_TradeHoldRequestResource(hhId)
            .setAccountId(finAcc.Id)
            .setAccountNumber(finAcc.FinServ__FinancialAccountNumber__c)
            .setCustodian('SCHWABINST')
            .setTradeHoldNote('reasonNotes')
            .setTradeHold(true);
        
        Test.startTest();
        
        // Mock the HTTP callout response
        HttpCalloutMock mock = new MSP_TradeHoldMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method to be tested
        HttpCalloutBuilder.HttpCalloutResponse response = resTradeHoldStatus.getTradeHold();
        Test.stopTest();
		
        MSP_TradeHoldRequestResource.MSP_GetTradeHoldResponseResource tradeHoldResponse = (MSP_TradeHoldRequestResource.MSP_GetTradeHoldResponseResource) response.parsedResponse;
        //Assert that trade hold response is true. MSP_GetTradeHoldResponseResource sendTradeHoldRequest
        Assert.areEqual(tradeHoldResponse.isTradeHold, true, 'Trade hold is set as true');
    }
}