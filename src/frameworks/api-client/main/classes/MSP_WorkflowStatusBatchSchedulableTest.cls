@isTest
private with sharing class MSP_WorkflowStatusBatchSchedulableTest {

    @isTest
    static void testExecute() {
        // Create test data
        Test.startTest();
        
        // Schedule the job
        MSP_WorkflowStatusTrackBatchSchedulable schedulable = new MSP_WorkflowStatusTrackBatchSchedulable();
        String jobId = System.schedule('Test Job', '0 0 0 1 1 ? 2030', schedulable);
        
        // Verify that the job is scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0 1 1 ? 2030', ct.CronExpression, 'Cron expression should not be null');
        
        // Simulate the execution of the scheduled job
        Test.stopTest();
        
        // Verify that the batch job was executed
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobType, ApexClass.Name 
                                   FROM AsyncApexJob 
                                   WHERE JobType = 'BatchApex' 
                                   AND ApexClass.Name = 'MSP_WorkflowStatusTrackBatch'];
        System.assertEquals(1, jobs.size(), 'There should be a job in queue');
        System.assertEquals('Queued', jobs[0].Status, 'Status should be queued.');
    }

}