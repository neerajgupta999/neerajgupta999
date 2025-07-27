public class ErrorLogger {
    
    //Marking this flag as true during execution would not rethrow the exception and would let the user code handle the messaging.
    public static boolean suppressException = false;
    
    @TestVisible private static boolean isTestRun = false;

    private static String strError;
    
    public static void logError(Exception ex) {
        logError(ex, null);
    }
    
    public static void  logError(Exception ex, String addInfo) {
        logError(new ErrorInfo(null,null,null,addInfo), ex);
    }
    
    public static void logError(String error) {
        logError(new LoggedException(error));
    }

    //PLANHUB-114531 - Capture more information into Error Log
    public static void logDetailedError(String error, String recId, String callerInstance, Exception ex) {
        Exception newEx = ex;
        if(ex == null && String.isNotBlank(error)){
            newEx = new LoggedException(error);
        }
        String trimmedError = error.length() > 255 ? error.substring(0, 255) : error;
        ErrorLogger.ErrorInfo errInfo = new ErrorLogger.ErrorInfo(trimmedError,recId,callerInstance,error);
        ErrorLogger.logError(errInfo,newEx);
    }
    
    public static void logError(ErrorInfo info, Exception ex){
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Running_User__c = UserInfo.getUserId();
        errorLog.Error_Type__c = ex.getTypeName();
        errorLog.Short_Description__c = info.shortDesc;// != null ? info.shortDesc : '';
        errorLog.Record_Id__c = info.recordId != null ? info.recordId : '';
        errorLog.Caller__c = info.caller != null ? info.caller : '';
        errorLog.Message__c = ex.getMessage()+'\r\nStack Trace\r\n------------\r\n'+ex.getStackTraceString()+'.';
        
        if(String.isNotBlank(info.addInfo) && info.addInfo.length() > Constant.TEXTAREA_LONG_MAX_LENGTH){
            info.addInfo = info.addInfo.substring(0, Constant.TEXTAREA_LONG_MAX_LENGTH);    
        }
        
        errorLog.Additional_Info__c = info.addInfo;
        logSystemDmlException(errorLog, ex);

        publishErrorLogEvent(errorLog);
        
        if(Test.isRunningTest()){
            isTestRun = true;
        }
        
        if(suppressException == false){
            throw ex;
        }
    }

    @TestVisible
    private static void logSystemDmlException(Error_Log__c errorLog, Exception ex){
        if (('System.DmlException').equals(errorLog.Error_Type__c)) {
            errorLog.DML_Exception_Details__c = '';
            
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                errorLog.DML_Exception_Details__c+= 'Record ID: '+ex.getDmlId(i) +
                    +' Error: ['+ex.getDmlType(i)+' - '+ex.getDmlFields(i)+'] \r\n'+ ex.getDmlMessage(i)
                    +'\r\n\r\n';
            }
            String strDMLExceptionDetails = errorLog.DML_Exception_Details__c;
            if(String.isNotBlank(strDMLExceptionDetails) && strDMLExceptionDetails.length() > Constant.TEXTAREA_LONG_MAX_LENGTH){
                errorLog.DML_Exception_Details__c = strDMLExceptionDetails.substring(0, Constant.TEXTAREA_LONG_MAX_LENGTH);
            }
        }  
        
    }
    
    private static void publishErrorLogEvent(Error_Log__c errorLog){
        Error_Log_Event__e anErrorLogEvent = new Error_Log_Event__e();

        anErrorLogEvent.Additional_Info__c = errorLog.Additional_Info__c;
        anErrorLogEvent.DML_Exception_Details__c = errorLog.DML_Exception_Details__c;
        anErrorLogEvent.Error_Type__c = errorLog.Error_Type__c;
        anErrorLogEvent.Message__c = errorLog.Message__c;
        anErrorLogEvent.Running_User__c = UserInfo.getUserId();
        anErrorLogEvent.Caller__c = errorLog.Caller__c;
        anErrorLogEvent.Record_Id__c = errorLog.Record_Id__c;
        anErrorLogEvent.Short_Description__c = errorLog.Short_Description__c;
        anErrorLogEvent.Http_End_Point__c = errorLog.Http_End_Point__c;
        anErrorLogEvent.Http_Method__c = errorLog.Http_Method__c;
        anErrorLogEvent.Http_Status_Code__c = errorLog.Http_Status_Code__c;
        anErrorLogEvent.Http_Request__c = errorLog.Http_request__c;
        EventBus.publish(anErrorLogEvent);
    }
    

    public static void logCalloutErrors(Exception ex, HttpRequest req, HttpResponse res) {
        Http_Callout_Setting__mdt calloutSetting = HttpCalloutBuilder.getCalloutSetting(req.getEndpoint(), req.getMethod());
        System.debug('+++callout setting: ' + calloutSetting);
        if (calloutSetting == null || !calloutSetting.Skip_Error_Log__c) {
            Error_Log__c errorLog = new Error_Log__c();
           
            if (req != null) {
                errorLog.Http_End_Point__c = req.getEndpoint();
                errorLog.Http_Method__c = req.getMethod();
                errorLog.Http_Request__c = req.getBody();
                if (String.isNotBlank(errorLog.Http_Request__c) && errorLog.Http_Request__c.length() > Constant.TEXTAREA_LONG_MAX_LENGTH) {
                    errorLog.Http_Request__c = errorLog.Http_Request__c.substring(0, Constant.TEXTAREA_LONG_MAX_LENGTH);
                }
            }
            if (res != null) {
                errorLog.Http_Status_Code__c = String.valueOf(res.getStatusCode());
                errorLog.Additional_Info__c = res?.getBody();
            }
            errorLog.Running_User__c = UserInfo.getUserId();
            errorLog.Error_Type__c = ex.getTypeName();
            errorLog.Short_Description__c = String.isNotBlank(ex.getMessage()) && ex.getMessage().length() > 255 ? ex.getMessage().substring(0, 255) : ex.getMessage();
            errorLog.Message__c = 'Error Message\r\n------------\r\n' + ex.getMessage() + '\r\nStack Trace\r\n------------\r\n' + ex.getStackTraceString();

            publishErrorLogEvent(errorLog);

            if (!suppressException) {
                throw ex;
            }
        }
    }
    
    
    // inner class for error description 
    public class ErrorInfo{
        public String shortDesc;
        public String recordId;
        public String caller;
        public String addInfo;
        public ErrorInfo(String shortDesc, String recordId, String caller, String addInfo){
            this.shortDesc = shortDesc;
            this.recordId = recordId;
            this.caller = caller;
            this.addInfo = addInfo;
        }
    }
}