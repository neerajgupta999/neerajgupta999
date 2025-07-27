public with sharing class MSP_WorkflowStatusTrackBatch implements Database.Batchable<SObject> {
    //RUNNING | SUCCEEDED | FAILED | TIMED_OUT | ABORTED | PENDING_REDRIVE
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        Set<String> mspWorkflowStatus = new Set<String>{'RUNNING', 'started', 'PENDING_REDRIVE'};
        String query = 'SELECT Id, MSP_Workflow_Status__c, MSP_Token__c, HouseholdAccount__c, type, Account_Opening_Provision_Status__c, MSP_Response__c ' 
                    + 'FROM Case ' + 
                    + 'WHERE MSP_Token__c != null AND MSP_Workflow_Status__c in :mspWorkflowStatus';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchContext, List<Case> scope) {
        System.enqueueJob(new MSP_WorkflowtatusCalloutHandler(scope));
    }

    public void finish(Database.BatchableContext batchContext) {
         System.debug(LoggingLevel.FINE, 'Batch execution finished');
    }
}