@isTest
public with sharing class MSP_WorkflowStatusTrackBatchTest {
    
    @testSetup
    static void setup() {
        User planner = [Select Id from User Where SSO_username__c != null and isActive = true limit 1];
        Account acc = CreateTestRecordUtils.createAccountWithPlanner('Test::SELF', null, null, planner.Id ,true);
        Account hhAccount  = [SElect Id from Account where FE_External_ID__c = 'Test'];
        Id UNENROLLMENT_SERVICE_REQUEST_CASE_RECORD_TYPE = RecordTypeUtil.getRecordTypeIdBySObjectAndDeveloperName('Case', RecordTypeUtil.CASE_TYPE_UNENROLLMENT_SERVICE_REQUEST);

        // Create test data
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 10; i++) {
            Case caseObj = new Case();
            caseObj.MSP_Workflow_Status__c = 'started';
            caseObj.MSP_Token__c = 'TestToken' + i;
            caseObj.RecordTypeId = UNENROLLMENT_SERVICE_REQUEST_CASE_RECORD_TYPE;
            caseObj.Type = TerminationSubmitActionInvocable.CASE_TERMINATE_SERVICE_REQUEST_RECORDTYPE;
            caseObj.HouseholdAccount__c = hhAccount.Id;
            cases.add(caseObj);
        }
        insert cases;
    }
    
    @isTest
    static void testBatchable() {
        Test.setMock(HttpCalloutMock.class, new MSP_HttpCalloutMock());
        Test.startTest();
        MSP_WorkflowStatusTrackBatch batch = new MSP_WorkflowStatusTrackBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        system.assertEquals(10, [Select Id from Case Where MSP_Workflow_Status__c = 'SUCCEEDED'].size(), 'All 10 cases should have succeeded.');

    }
}