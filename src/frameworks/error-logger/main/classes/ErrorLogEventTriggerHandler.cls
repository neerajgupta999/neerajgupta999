public class ErrorLogEventTriggerHandler extends TriggerHandler {

    protected override void afterInsert() {
        List<Error_Log__c> lstErrorLog = new List<Error_Log__c>();

        for(Error_Log_Event__e anErrorLogEvent: (List<Error_Log_Event__e>)Trigger.New){
            
            Error_Log__c anErrorLog = new Error_Log__c();
            
            anErrorLog.Additional_Info__c = anErrorLogEvent.Additional_Info__c;
            anErrorLog.DML_Exception_Details__c = anErrorLogEvent.DML_Exception_Details__c;
            anErrorLog.Error_Type__c = anErrorLogEvent.Error_Type__c;
            anErrorLog.Message__c = anErrorLogEvent.Message__c;
            anErrorLog.OwnerId  = Id.valueOf(anErrorLogEvent.Running_User__c);
            anErrorLog.Running_User__c  = Id.valueOf(anErrorLogEvent.Running_User__c);
            anErrorLog.Caller__c = anErrorLogEvent.Caller__c;
            anErrorLog.Record_Id__c  = anErrorLogEvent.Record_Id__c;
            anErrorLog.Short_Description__c  = anErrorLogEvent.Short_Description__c;
            anErrorLog.Http_End_Point__c  = anErrorLogEvent.Http_End_Point__c;
            anErrorLog.Http_Method__c  = anErrorLogEvent.Http_Method__c;
            anErrorLog.Http_Status_Code__c  = anErrorLogEvent.Http_Status_Code__c;
            anErrorLog.Http_Request__c = anErrorLogEvent.Http_Request__c;

            lstErrorLog.add(anErrorLog);
        }
        
        if(lstErrorLog.isEmpty() == false){
            Database.insert(lstErrorLog);
        }        
    }
    
}