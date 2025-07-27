@isTest
public with sharing class MSP_WorkflowtatusCalloutHandlerTest {
    
    @testSetup
    static void setup() {
        User planner = [Select Id from User Where SSO_username__c != null and isActive = true limit 1];
        Account acc = CreateTestRecordUtils.createAccountWithPlanner('Test::SELF', null, null, planner.Id ,true);
        Account hhAccount  = [SElect Id from Account where FE_External_ID__c = 'Test'];
        Id UNENROLLMENT_SERVICE_REQUEST_CASE_RECORD_TYPE = RecordTypeUtil.getRecordTypeIdBySObjectAndDeveloperName('Case', RecordTypeUtil.CASE_TYPE_UNENROLLMENT_SERVICE_REQUEST);
		Id acctOpenCaseRecordTypeId = RecordTypeUtil.getRecordTypeIdBySObjectAndDeveloperName('Case', 'Account_Opening');
        
        // Create test data
        List<Case> cases = new List<Case>();

        Case caseObj = new Case();
        caseObj.MSP_Workflow_Status__c = 'started';
        caseObj.MSP_Token__c = 'TestToken1';
        caseObj.Type = TerminationSubmitActionInvocable.CASE_TERMINATE_SERVICE_REQUEST_RECORDTYPE;
        caseObj.HouseholdAccount__c = hhAccount.Id;
        caseObj.RecordTypeId = UNENROLLMENT_SERVICE_REQUEST_CASE_RECORD_TYPE;
        cases.add(caseObj);

        caseObj = new Case();
        caseObj.MSP_Workflow_Status__c = 'started';
        caseObj.MSP_Token__c = 'TestToken1';
        caseObj.Type = TerminationSubmitActionInvocable.CASE_TERMINATE_SERVICE_REQUEST_RECORDTYPE;
        caseObj.RecordTypeId = UNENROLLMENT_SERVICE_REQUEST_CASE_RECORD_TYPE;
        cases.add(caseObj);
        
        insert cases;
    }
    
    @isTest
    static void testTerminateMSPWorkflow() {
        Test.setMock(HttpCalloutMock.class, new MSP_HttpCalloutMock());
        Test.startTest();
        System.enqueueJob(new MSP_WorkflowtatusCalloutHandler([Select Id, HouseholdAccount__c, type, MSP_Token__c, Account_Opening_Provision_Status__c, MSP_Response__c from Case]));
        Test.stopTest();
        system.assertEquals(1, [Select Id  from Case Where MSP_Workflow_Status__c = 'SUCCEEDED'].size(), '1 case should have succeeded.');
        system.assertEquals(1, [Select Id  from Case Where MSP_Workflow_Status__c != 'SUCCEEDED'].size(), '1 cases should fail.');

    }
    
    @isTest
    static void testOnboardingMSPWorkflow() {
        CreateTestRecordUtils.setFinServPersonAccountFlag(true);
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<User> lstUser = new List<User>();
        User plannerA;
        System.runAs(u){
            plannerA = CreateTestRecordUtils.createTestUser('Field Advisor Dragonfly1', 'AliasAB', false);
            lstUser.add(plannerA);
            insert lstUser;
        }
        
        Account primaryAcct = CreateTestRecordUtils.createRetail2Account('getNonCustFinAcctsUsingCaseID::SELF');
        primaryAcct.Assigned_Adviser__c = plannerA.Id;
        update primaryAcct;
        
        Map<Id,Set<Id>> relatedHHIdsByPersonAccount = HouseholdDao.getRelatedHouseholdIds(new Set<Id>{primaryAcct.Id});
        Id hhId = new List<Id> (relatedHHIdsByPersonAccount.get(primaryAcct.Id)).get(0);
        Account household = [SELECT Id, Assigned_Adviser__c FROM Account WHERE ID =: hhId];
        household.Assigned_Adviser__c = plannerA.Id;
        update household;
        
        List<Case> lstCases = new List<Case>();
        Id acctOpenCaseRecordTypeId = RecordTypeUtil.getRecordTypeIdBySObjectAndDeveloperName('Case', 'Account_Opening');
        Case testCase1 = CreateTestRecordUtils.createCase('Case1', acctOpenCaseRecordTypeId, 'Provisioning', hhId, false);
        Case testCase2 = CreateTestRecordUtils.createCase('Case2', acctOpenCaseRecordTypeId, 'Provisioning', null, false);
        lstCases.add(testCase1);
        lstCases.add(testCase2);
        insert lstCases;
        testCase1.Account_Opening_Provision_Status__c = 'MSP Request Sent';
        testCase1.MSP_Response__c='{"status": "started","token": "test-token"}';
        testCase1.HouseholdAccount__c = hhId;
        testCase1.MSP_Workflow_Status__c = 'started';
        testCase1.type = Constant.CASE_TYPE_ACCOUNT_OPENING;
        update testCase1;
        testCase2.Account_Opening_Provision_Status__c = 'MSP Request Sent';
        testCase2.MSP_Response__c='{"status": "started","token": "test-token"}';
        testCase2.HouseholdAccount__c = null;
        testCase2.MSP_Workflow_Status__c = 'started';
        testCase2.type = Constant.CASE_TYPE_ACCOUNT_OPENING;
        update testCase2;

        List<FinServ__FinancialAccount__c> lstFinAccounts = new List<FinServ__FinancialAccount__c>();
        FinServ__FinancialAccount__c testFinAccount1 = CreateTestRecordUtils.createFinAccountGeneral(primaryAcct.Id, 'finAcct1',false);
        FinServ__FinancialAccount__c testFinAccount2 = CreateTestRecordUtils.createFinAccountGeneral(primaryAcct.Id, 'finAcct2',false);
        testFinAccount1.Created_At_Custodian__c = 'No';
        testFinAccount2.Created_At_Custodian__c = 'Yes';
        lstFinAccounts.add(testFinAccount1);
        lstFinAccounts.add(testFinAccount2);
        insert lstFinAccounts;

        List<Case_FinancialAccount_Junction__c> caseFinAcctList = new List<Case_FinancialAccount_Junction__c>();
        caseFinAcctList.add(createCaseFinAccount(testCase1, testFinAccount1, 'Submitted'));
        caseFinAcctList.add(createCaseFinAccount(testCase1, testFinAccount2, 'Submitted'));
        insert caseFinAcctList;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SubmitAccountOnboardingQueueableMock());
        List<Case> csList = [Select Id, HouseholdAccount__c, type, MSP_Token__c, Account_Opening_Provision_Status__c, MSP_Response__c FROM Case WHERE recordTypeId =: acctOpenCaseRecordTypeId];        
        System.enqueueJob(new MSP_WorkflowtatusCalloutHandler(csList));
        Test.stopTest();
        system.assertEquals(2, [Select Id  from Case Where MSP_Workflow_Status__c != 'SUCCEEDED' AND recordTypeId =: acctOpenCaseRecordTypeId].size(), '2 cases should fail.');
    }
    
    private static Case_FinancialAccount_Junction__c createCaseFinAccount(Case cse, FinServ__FinancialAccount__c finAcct, String serviceRequestStatus ){

        Id delinkCasFinAcctRecordTypeId = RecordTypeUtil.getServiceRecordTypeIdByObjectTypeAndName('Case_FinancialAccount_Junction__c','Field Delink Form');
        Case_FinancialAccount_Junction__c caseFinAcct = new Case_FinancialAccount_Junction__c();
        caseFinAcct.CaseId__c = cse?.Id;
        caseFinAcct.FinAcctId__c = finAcct.Id;
        caseFinAcct.Name = finAcct.Name;
        caseFinAcct.Primary_Owner__c = finAcct.FinServ__PrimaryOwner__c;
        caseFinAcct.Account_Number__c = finAcct.FinServ__FinancialAccountNumber__c;
        caseFinAcct.Service_Request_Status__c = serviceRequestStatus;
        caseFinAcct.RecordTypeId = delinkCasFinAcctRecordTypeId;

        return caseFinAcct;
    }
	
}