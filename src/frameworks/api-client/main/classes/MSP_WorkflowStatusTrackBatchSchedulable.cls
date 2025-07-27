public with sharing class MSP_WorkflowStatusTrackBatchSchedulable implements Schedulable {
    public void execute(SchedulableContext schedulableContext) {
        // Check if there is an in-progress batch job
        List<AsyncApexJob> jobs = [SELECT Id, Status 
                                    FROM AsyncApexJob 
                                    WHERE JobType = 'BatchApex' 
                                    AND Status = 'Processing' 
                                    AND APEXCLASS.Name = 'MSP_WorkflowStatusTrackBatch'];
        
        if (jobs.isEmpty()) {
            Database.executeBatch(new MSP_WorkflowStatusTrackBatch(), 10);
        }
    }
}