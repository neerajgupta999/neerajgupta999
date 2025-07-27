@isTest
private class ErrorLogEventTriggerHandlerTest {
    
    private static final String TESTSTRING = 'Test';
    
    @isTest
    static void testException(){
        Boolean bDoesFail = false;
        try{
            Error_Log_Event__e anErrorLogEvent = new Error_Log_Event__e();
            anErrorLogEvent.Error_Type__c = 'TriggerExceptionTest';
            
            insert anErrorLogEvent;
        }catch(Exception e){
            bDoesFail = true;
            System.debug('exception '+e.getTypeName());
        }
        System.assert(bDoesFail, 'Error_Log_Event__e exception test should throw an exception.');
    }
    
    @isTest
    static void testErrorLogEventTriggerInsert(){
        ErrorLogger.suppressException = true;
        try{
            Test.startTest();
            
            ErrorLogger.logError(new LoggedException(), 'ErrorLogEventTriggerHandlerTest.testErrorLogEventTriggerInsert');
            
            Test.stopTest();
            
            ErrorLogger.suppressException = false;
        }catch(Exception e){
            System.assert(false, 'Unexpected error in ErrorLogEventTriggerHandlerTest.testErrorLogEventTriggerInsert '+e.getMessage());
        }
        
        List<Error_Log__c> lstErrorLog = [SELECT Id, Name, Additional_Info__c FROM Error_Log__c];
        
        System.assertEquals('ErrorLogEventTriggerHandlerTest.testErrorLogEventTriggerInsert', lstErrorLog[0].Additional_Info__c);
    }
    
    @isTest
    static void testErrLogEvtTriggerAdditionalFields(){
        ErrorLogger.suppressException = true;
        try{
            Test.startTest();
            
            ErrorLogger.ErrorInfo info = new ErrorLogger.ErrorInfo(TESTSTRING,TESTSTRING,TESTSTRING,null);
            ErrorLogger.logError(info,new LoggedException());
            
            Test.stopTest();
            
            ErrorLogger.suppressException = false;
        }catch(Exception e){
            System.assert(false, 'Unexpected error in ErrorLogEventTriggerHandlerTest.testErrorLogEventTriggerInsert '+e.getMessage());
        }
        
        List<Error_Log__c> lstErrorLog = [SELECT Id, Name, Additional_Info__c, DML_Exception_Details__c, Error_Type__c, Message__c,
                                          Running_User__c, Caller__c, Record_Id__c, Short_Description__c FROM Error_Log__c];
        
        
        System.assert(String.isNotBlank(lstErrorLog[0].Caller__c), 'Caller is not null');
        System.assert(String.isNotBlank(lstErrorLog[0].Record_Id__c), 'Record Id is not null');
        System.assert(String.isNotBlank(lstErrorLog[0].Short_Description__c), 'Short Description is not null');
    }
    
}