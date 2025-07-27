@isTest
public class MSP_SetAsideCashRequestResourceTest {
    
    private static Id finAccGeneralRecTypeId = RecordTypeUtil.getFinancialAccountRecordTypeIdByName(RecordTypeUtil.FINANCIAL_ACCOUNT_GENERAL_ACCOUNT);
    private static final String USER_ALIAS = 'Planner';
    
    // Create Test Data
    @testSetup
    private static void setup(){
        User planner = CreateTestRecordUtils.createTestUser('Field Advisor Dragonfly1', USER_ALIAS ,false);
        planner.email = 'MSP_APIClientBaseTest@fngn.com';
        planner.SSO_username__c = USER_ALIAS;
        insert planner;
        
    }
    
    @isTest
    static void testCreateSetAsideCashRequest() {
        
        User planner = [SELECT Id FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
        CreateTestRecordUtils.setFinServPersonAccountFlag(true);
        Account primaryAcc = new Account(FirstName = 'Primary',LastName = 'Account',Email__c='primary@test.com',Assigned_Adviser__c= planner.Id);
        insert primaryAcc;
        Id hhId = HouseholdDao.getAccidWithHHids(new List<Id>{primaryAcc.Id}).values()[0];
        FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(Name = 'Test',
                                                                                RecordTypeId = RecordTypeUtil.getFinancialAccountRecordTypeIdByName(Constant.FINANCIAL_ACCOUNT_GENERAL_ACCOUNT), 
                                                                                Estimated_Account_Value__c = 50000,
                                                                                FinServ__FinancialAccountNumber__c = '72727272',
                                                                                FinServ__PrimaryOwner__c = primaryAcc.Id,
                                                                                Custodian__c = Constant.CUSTODIAN_CHARLES_SCHWAB,
                                                                                FinServ__Household__c = hhId);
        insert finAcc;
        
        // Create a mock response
        HttpCalloutMock mock = new MSP_SetAsideCashMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Create request parameters
        MSP_SetAsideCashRequestResource.createSetAsideCashRequestParm reqParam = new MSP_SetAsideCashRequestResource.createSetAsideCashRequestParm();
        reqParam.setCustodian(Constant.CUSTODIAN_CHARLES_SCHWAB);
        reqParam.setAccountNumber(finAcc.FinServ__FinancialAccountNumber__c);
        reqParam.setHouseholdId(hhId);
        reqParam.setbody(new MSP_SetAsideCashRequestResource.SetAsideCashRequestDto());
        
        // Call the method
        MSP_SetAsideCashRequestResource resource = new MSP_SetAsideCashRequestResource();
        HttpCalloutBuilder.HttpCalloutResponse response = resource.createSetAsideCashRequest(reqParam);
        
        // Verify the response
        System.assertNotEquals(null, response);
        MSP_SetAsideCashRequestResource.SetAsideCashCreateResponsetDto responseDto = (MSP_SetAsideCashRequestResource.SetAsideCashCreateResponsetDto) response.parsedResponse;
        //System.assertEquals(10, responseDto.id);
    
    }
    
    @isTest
    static void testGetSetAsideCash() {
        
        User planner = [SELECT Id FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
        CreateTestRecordUtils.setFinServPersonAccountFlag(true);
        Account primaryAcc = new Account(FirstName = 'Primary',LastName = 'Account',Email__c='primary@test.com',Assigned_Adviser__c= planner.Id);
        insert primaryAcc;
        Id hhId = HouseholdDao.getAccidWithHHids(new List<Id>{primaryAcc.Id}).values()[0];
        FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(Name = 'Test',
                                                                                RecordTypeId = RecordTypeUtil.getFinancialAccountRecordTypeIdByName(Constant.FINANCIAL_ACCOUNT_GENERAL_ACCOUNT), 
                                                                                Estimated_Account_Value__c = 50000,
                                                                                FinServ__FinancialAccountNumber__c = '72727272',
                                                                                FinServ__PrimaryOwner__c = primaryAcc.Id,
                                                                                Custodian__c = Constant.CUSTODIAN_CHARLES_SCHWAB,
                                                                                FinServ__Household__c = hhId);
        insert finAcc;
        
        // Create a mock response
        HttpCalloutMock mock = new MSP_SetAsideCashMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Create request parameters
        MSP_SetAsideCashRequestResource.getSetAsideCashRequestParm reqParam = new MSP_SetAsideCashRequestResource.getSetAsideCashRequestParm();
        reqParam.setCustodian(Constant.CUSTODIAN_CHARLES_SCHWAB);
        reqParam.setAccountNumber(finAcc.FinServ__FinancialAccountNumber__c);
        reqParam.setHouseholdId(hhId);
        reqParam.setCashAsideId(1);
        
        // Call the method
        MSP_SetAsideCashRequestResource resource = new MSP_SetAsideCashRequestResource();
        HttpCalloutBuilder.HttpCalloutResponse response = resource.getSetAsideCashRequest(reqParam);
        
        // Verify the response
        System.assertNotEquals(null, response);
    }
    
    @isTest
    static void testDeleteSetAsideCash() {
        
        User planner = [SELECT Id FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
        CreateTestRecordUtils.setFinServPersonAccountFlag(true);
        Account primaryAcc = new Account(FirstName = 'Primary',LastName = 'Account',Email__c='primary@test.com',Assigned_Adviser__c= planner.Id);
        insert primaryAcc;
        Id hhId = HouseholdDao.getAccidWithHHids(new List<Id>{primaryAcc.Id}).values()[0];
        FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(Name = 'Test',
                                                                                RecordTypeId = RecordTypeUtil.getFinancialAccountRecordTypeIdByName(Constant.FINANCIAL_ACCOUNT_GENERAL_ACCOUNT), 
                                                                                Estimated_Account_Value__c = 50000,
                                                                                FinServ__FinancialAccountNumber__c = '72727272',
                                                                                FinServ__PrimaryOwner__c = primaryAcc.Id,
                                                                                Custodian__c = Constant.CUSTODIAN_CHARLES_SCHWAB,
                                                                                FinServ__Household__c = hhId);
        insert finAcc;
        
        // Create a mock response
        HttpCalloutMock mock = new MSP_SetAsideCashMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Create request parameters
        MSP_SetAsideCashRequestResource.deleteSetAsideCashRequestParm reqParam = new MSP_SetAsideCashRequestResource.deleteSetAsideCashRequestParm();
        reqParam.setCustodian(Constant.CUSTODIAN_CHARLES_SCHWAB);
        reqParam.setAccountNumber(finAcc.FinServ__FinancialAccountNumber__c);
        reqParam.setHouseholdId(hhId);
        reqParam.setCashAsideId(1);
        
        // Call the method
        MSP_SetAsideCashRequestResource resource = new MSP_SetAsideCashRequestResource();
        HttpCalloutBuilder.HttpCalloutResponse response = resource.deleteSetAsideCashRequest(reqParam);
        
        // Verify the response
        System.assertNotEquals(null, response);
    }
}