@isTest
private class MSP_OrionVFControllerTest {
    @isTest
    static void testGetDashboardLinkHousehold() {
        // Mock the HTTP callout response 
        HttpCalloutMock mock = new MSP_DeeplinkMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);

        Account household = [SELECT Id, Name, Assigned_Adviser__c, Assigned_Adviser__r.Name FROM Account WHERE recordtype.name = 'Household' limit 1];

        // Instantiate the controller
        MSP_OrionVFController controller = new MSP_OrionVFController();
        controller.recordId = household.Id; // Replace with a valid household ID

        Test.startTest();
        // Call the method
        controller.getDashboardLinkHousehold();
        Test.stopTest();

        // Assert that the URL is not null
        System.assertNotEquals(null, controller.url, 'Expected URL to be not null');
        System.assertEquals('https://example.com/deeplink', controller.url, 'Expected URL to be https://example.com/deeplink');
    }

    @isTest
    static void testGetDashboardLinkPlanner() {
        // Similar setup as above for planner test

        // Instantiate the controller
        MSP_OrionVFController controller = new MSP_OrionVFController();
        String plannerId = [Select Id from User where isActive = true and SSO_username__c != null limit 1].get(0).Id;

        controller.recordId = plannerId; // Replace with a valid planner ID

        // Mock the HTTP callout response
        HttpCalloutMock mock = new MSP_DeeplinkMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        // Call the method
        controller.getDashboardLinkPlanner();
        Test.stopTest();

        // Assert that the URL is not null
        Assert.isTrue(controller.url != null, 'Expected URL to be not null');  
        Assert.isTrue('https://example.com/deeplink' == controller.url, 'Expected URL to be https://example.com/deeplink. Actual : ' + controller.url);

        // Add more assertions related to the planner dashboard link
    }

    @isTest
    static void testGetDashboardLinkPlannerRMD() {
        // Instantiate the controller
        MSP_OrionVFController controller = new MSP_OrionVFController();
        String plannerId = [Select Id from User where isActive = true and SSO_username__c != null limit 1].get(0).Id;

        controller.recordId = plannerId; // Replace with a valid planner ID

        // Mock the HTTP callout response
        HttpCalloutMock mock = new MSP_DeeplinkMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        // Call the method
        controller.getDashboardLinkRMD();
        Test.stopTest();

        // Assert that the URL is not null
        Assert.isTrue(controller.url != null, 'Expected URL to be not null');  
        Assert.isTrue('https://example.com/deeplink' == controller.url, 'Expected URL to be https://example.com/deeplink. Actual : ' + controller.url);
    }

    @isTest
    static void testGetDashboardLinkFinAccount() {
        MSP_OrionVFController controller = new MSP_OrionVFController();

        // Mock the HTTP callout response
        HttpCalloutMock mock = new MSP_DeeplinkMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        // Call the method
        FinServ__FinancialAccount__c finAccount = [Select Id, FinServ__Household__c  From FinServ__FinancialAccount__c Limit 1 ].get(0);
        controller.recordId = finAccount.Id;
        Assert.isTrue(finAccount.FinServ__Household__c != null, 'Expect Financial Account has household updated.');
        
        controller.getDashboardLinkFinAccount();
        Test.stopTest();

        // Assert that the URL is not null
        Assert.isTrue(controller.url != null, 'Expected URL to be not null');  
        Assert.isTrue('https://example.com/deeplink' == controller.url, 'Expected URL to be https://example.com/deeplink. Actual : ' + controller.url);
    }

    @testSetup static void createTestData() {
        CreateTestRecordUtils.setFinancialAccountDataQualityFeatureFlag(true);
        CreateTestRecordUtils.setFinServPersonAccountFlag(true);

        String plannerId = [Select Id from User where isActive = true and SSO_username__c != null limit 1].get(0).Id;

        Account aPrimaryAccount = CreateTestRecordUtils.createRetail2Account('FinancialAccountOwnerControllerTestPrimary::SELF');
        aPrimaryAccount.Assigned_Adviser__c = plannerId;
        update aPrimaryAccount;
                
        Account household = [
                            SELECT Id, Name, Assigned_Adviser__c, Assigned_Adviser__r.Name 
                            FROM Account 
                            WHERE recordtype.developername = 'IndustriesHousehold' limit 1];
        household.Assigned_Adviser__c = plannerId;
        update household;

        List<FinServ__FinancialAccount__c> lstFinAccounts = new List<FinServ__FinancialAccount__c>();
        FinServ__FinancialAccount__c testFinAccount1 = CreateTestRecordUtils.createFinAccountGeneral(aPrimaryAccount.Id,'testFinAccount1',false);
        
        testFinAccount1.FinServ__FinancialAccountNumber__c = '0123456789';
        testFinAccount1.Name += testFinAccount1.FinServ__FinancialAccountNumber__c;
        testFinAccount1.FinServ__Household__c = household.Id;
        testFinAccount1.Custodian__c = 'schwab';
        lstFinAccounts.add(testFinAccount1);
        insert lstFinAccounts;

        Assert.isTrue([Select Id, FinServ__Household__c  From FinServ__FinancialAccount__c Where id = :lstFinAccounts[0].Id].get(0).FinServ__Household__c != null, 'Expect FA to have household  updated.');
    }
}