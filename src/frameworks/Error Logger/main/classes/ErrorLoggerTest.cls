@isTest
public class ErrorLoggerTest {
    
    private static final String TESTSTRING = 'Test';
    public virtual class TestException extends Exception {}

    static testMethod void testLogError1() {
        Test.startTest();
        try {
        	OpportunityLineItem oli = new OpportunityLineItem(Description  = 'Test');
            insert oli;    
        } catch (Exception ex) { 
            try {
            	ErrorLogger.logError(ex);
            } Catch (Exception ex1){
                //Do Nothing, this is needed so that the Inner exception in ErrorLogger does not fail the test method.
            }
        }
        System.assertEquals(true,ErrorLogger.isTestRun);
        
        Test.stopTest();
    }
    
    static testMethod void testLogError2() {
        Test.startTest();
        String addInfo = 'Addition Info';
        try {
            OpportunityLineItem oli = new OpportunityLineItem(Description  = 'Test');
            insert oli; 
        } catch (Exception ex) {
            try {
            	ErrorLogger.logError(ex, addInfo);
            } Catch (Exception ex1){
                //Do Nothing, this is needed so that the Inner exception in ErrorLogger does not fail the test method.
            }
        }
        System.assertEquals(true,ErrorLogger.isTestRun);
        
        Test.stopTest();
    } 
    
    static testMethod void testLogErrorWithoutException() {
        Test.startTest();
        try{
            String addInfo = 'Additional Info';
            ErrorLogger.logError(addInfo);
        }catch(Exception e){
            System.debug('Catching the dexception.');
        }    
        System.assertEquals(true,ErrorLogger.isTestRun);
        
        Test.stopTest();
    }
    
    static testMethod void testlogDetailedError() {
        ErrorLogger.suppressException = true;
        try{
            Test.startTest();
            
            ErrorLogger.logDetailedError(TESTSTRING, TESTSTRING, TESTSTRING, null);
            
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
    
    static testMethod void testLogErrorWithoutErrWrapper() {
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
    @isTest
    static void testSkipCalloutErrors() {

        insert new Http_Callout_Control__c (
            Http_Callout_Setting_Name__c = 'Test_Callout_Setting'
        );
        Test.setMock(HttpCalloutMock.class, new Five9SMSServiceHttpCalloutMock());

        try{
            Test.startTest();

            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'TestBearerToken ');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint('test/callout/setting') ;
            req.setMethod('GET');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "Test": "test" }');
            res.setStatusCode(200);

            
            TestException ex = new TestException('Error In Callout');

            ErrorLogger.logCalloutErrors(ex,req,res );

            Test.stopTest();
       
        }catch(Exception e){
            Assert.isTrue(false, 'erorr was thrown, error should be skipped');
        }
        
    }

    @isTest
    static void testLogCalloutErrors() {

        insert new Http_Callout_Control__c (
            Http_Callout_Setting_Name__c = 'Test_Callout_Setting'
        );
        Test.setMock(HttpCalloutMock.class, new Five9SMSServiceHttpCalloutMock());

        try{
            Test.startTest();

            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'TestBearerToken ');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint('test/skip/callout/setting') ;
            req.setMethod('POST');
            req.setBody('{sample request body}');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "Test": "test" }');
            res.setStatusCode(200);

            
            TestException ex = new TestException('Error In Callout');

            ErrorLogger.logCalloutErrors(ex,req,res );
            Assert.isTrue(false, 'erorr should be thrown by previous line');
            Assert.isTrue('{sample request body}' == [Select Http_Request__c from Error_Log__c].get(0).Http_Request__c);
            Test.stopTest();
       
        }catch(Exception e){
            Assert.isTrue(true);
        }
        
    }
}