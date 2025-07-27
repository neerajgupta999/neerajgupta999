@isTest
private with sharing class MSP_WorkflowsTerminateAPIClientTest {
    @testSetup
    static void setup() {
        User planner = [Select Id from User Where SSO_username__c != null and isActive = true limit 1];
        Account acc = CreateTestRecordUtils.createAccountWithPlanner('Test::SELF', null, null, planner.Id ,true);
        Account hhAccount  = [SElect Id from Account where FE_External_ID__c = 'Test'];
        // Create test data
        List<Case> cases = new List<Case>();
        Case caseObj = new Case();
        Case newCase = CreateTestRecordUtils.createCase('Test Subject', null, 'New', acc.Id, false);
        caseObj.Type = TerminationSubmitActionInvocable.CASE_TERMINATE_SERVICE_REQUEST_RECORDTYPE;
        caseObj.HouseholdAccount__c = hhAccount.Id;
        cases.add(caseObj);
        insert cases;
    }

    @isTest
    static void testMSPTerminatePost() { 
        Test.setMock(HttpCalloutMock.class, new MSP_HttpCalloutMock());
        
        Id householdId = [SElect Id from Account where FE_External_ID__c = 'Test'].get(0).Id;
        MSP_WorkflowsTerminateAPIClient apiClient = new MSP_WorkflowsTerminateAPIClient(householdId);

        MSP_TerminationDto terminationRequest = new MSP_TerminationDto();
        terminationRequest.createFinalBill = true;
        terminationRequest.entityId = 'Test';
        terminationRequest.entityType = 'HOUSEHOLD';
        terminationRequest.liquidateModelHoldings = true;
        apiClient.terminate(terminationRequest);

        Test.startTest();
        HttpCalloutBuilder.HttpCalloutResponse response = apiClient.terminate(terminationRequest);
        Test.stopTest();
        Assert.isTrue(response.isSuccess, 'API call should be successful');
        Assert.isTrue(response.calloutException == null, 'There should be no callout Errors');
        Assert.isTrue(response.parsedResponse != null, 'Parsed response should not be empty.');
        MSP_WorkflowStatusDto parsedResp = (MSP_WorkflowStatusDto) response.parsedResponse;
        
        Assert.isTrue(parsedResp.token == '5128859e-9db3-4cf9-b6d9-f96ee1259531', 'Expected Token');
        Assert.isTrue(parsedResp.status == 'SUCCEEDED', 'API Reponse status should be SUCCEEDED.');
    }
    @isTest
    static void testMSPTerminateGet() {
        Test.setMock(HttpCalloutMock.class, new MSP_HttpCalloutMock());
        
        Id householdId = [SElect Id from Account where FE_External_ID__c = 'Test'].get(0).Id;
        MSP_WorkflowsTerminateAPIClient apiClient = new MSP_WorkflowsTerminateAPIClient(householdId);

        Test.startTest();
        HttpCalloutBuilder.HttpCalloutResponse response = apiClient.getStatus('5128859e-9db3-4cf9-b6d9-f96ee1259531');
        Test.stopTest();
        Assert.isTrue(response.isSuccess, 'API call should be successful');
        Assert.isTrue(response.calloutException == null, 'There should be no callout Errors');
        Assert.isTrue(response.parsedResponse != null, 'Parsed response should not be empty.');
        MSP_WorkflowStatusDto parsedResp = (MSP_WorkflowStatusDto) response.parsedResponse;
        
        Assert.isTrue(parsedResp.token == '5128859e-9db3-4cf9-b6d9-f96ee1259531', 'Expected Token');
        Assert.isTrue(parsedResp.status == 'SUCCEEDED', 'API Reponse status should be SUCCEEDED.');
    }

}