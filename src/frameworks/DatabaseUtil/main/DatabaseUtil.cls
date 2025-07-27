public class DatabaseUtil {

    public static List<Database.SaveResult> updateSObjectAllowPartial(List<SObject> lstSObject){        
        return updateSObject(lstSObject, false);        
    }

    public static List<Database.SaveResult> updateSObjectDoNotAllowPartial(List<SObject> lstSObject){
        return updateSObject(lstSObject, true);
    }

    public static List<Database.SaveResult> insertSObjectAllowPartial(List<SObject> lstSObject){
        return insertSObject(lstSObject, false);
    }

    public static List<Database.SaveResult> insertSObjectDoNotAllowPartial(List<SObject> lstSObject){
        return insertSObject(lstSObject, true);
    }

    public static List<Database.UpsertResult> upsertSObjectAllowPartial(List<SObject> lstSObject){
        return upsertSObject(lstSObject, false);
    }

    public static List<Database.UpsertResult> upsertSObjectDoNotAllowPartial(List<SObject> lstSObject){
        return upsertSObject(lstSObject, true);
    }

    public static List<Database.DeleteResult> deleteSObjectAllowPartial(List<SObject> lstSObject){
        return deleteSObject(lstSObject, false);
    }

    public static List<Database.DeleteResult> deleteSObjectDoNotAllowPartial(List<SObject> lstSObject){
        return deleteSObject(lstSObject, true);
    }


    @TestVisible
    private static List<Database.SaveResult> updateSObject(List<SObject> lstSObject, Boolean bAllOrNone){
        System.debug('DatabaseUtil.updateSObject() START');
        List<Database.SaveResult> lstSaveResult = null;

        if(lstSObject != null && lstSObject.isEmpty() == false){
            lstSaveResult = Database.update(lstSObject, bAllOrNone);

            processDMLResults(lstSaveResult, bAllOrNone);
        }
        System.debug('DatabaseUtil.updateSObject() END');
        return lstSaveResult;
    }

    @TestVisible
    private static List<Database.SaveResult> insertSObject(List<SObject> lstSObject, Boolean bAllOrNone){
        System.debug('DatabaseUtil.insertSObject() START');
        List<Database.SaveResult> lstSaveResult = null;

        if(lstSObject != null && lstSObject.isEmpty() == false){
            lstSaveResult = Database.insert(lstSObject, bAllOrNone);
            
            processDMLResults(lstSaveResult, bAllOrNone);
        }
        System.debug('DatabaseUtil.insertSObject() END');
        return lstSaveResult;
    }    

    @TestVisible
    private static List<Database.UpsertResult> upsertSObject(List<SObject> lstSObject, Boolean bAllOrNone){
        System.debug('DatabaseUtil.upsertSObject() START');
        List<Database.UpsertResult> lstUpsertResult = null;

        if(lstSObject != null && lstSObject.isEmpty() == false){
            lstUpsertResult = Database.upsert(lstSObject, bAllOrNone);
            
            processDMLResults(lstUpsertResult, bAllOrNone);
        }
        System.debug('DatabaseUtil.upsertSObject() END');
        return lstUpsertResult;
    } 

    @TestVisible
    private static List<Database.DeleteResult> deleteSObject(List<SObject> lstSObject, Boolean bAllOrNone){
        System.debug('DatabaseUtil.deleteSObject() START');
        List<Database.DeleteResult> lstDeleteResult = null;
        String strError = '';
        
        if(lstSObject != null && lstSObject.isEmpty() == false){
            lstDeleteResult = Database.delete(lstSObject, bAllOrNone);
            
            processDMLResults(lstDeleteResult, bAllOrNone);

        }
        System.debug('DatabaseUtil.deleteSObject() END');
        return lstDeleteResult;
    }

    @TestVisible
    private static void processDMLResults(Database.DeleteResult[] lstDeleteResult, Boolean bThrowException){
        String strError = '';
        for(Database.DeleteResult dr : lstDeleteResult){
            if (dr.isSuccess() == false) {
                for(Database.Error err : dr.getErrors()) {
                    strError += 'Unable to delete record. Record id: ' + dr.getId() 
                            + ' Message: ' + err.getMessage() 
                            + ' fields that affected this error: ' + err.getFields() + '\n';               
                }
            }
        }
        if(String.isNotBlank(strError)) {
            if(!bThrowException){
                ErrorLogger.suppressException = true;
            }
            ErrorLogger.logError(strError);
            if(!bThrowException){
                ErrorLogger.suppressException = false;
            }
        }
    }

    @TestVisible
    private static void processDMLResults(Database.SaveResult[] lstSaveResult, Boolean bThrowException){
        String strError = '';
        for(Database.SaveResult aResult : lstSaveResult){
            if(aResult.isSuccess() == false){
                for (Database.Error err : aResult.getErrors()){
                    strError += 'Error during a DML. Record id: '+aResult.getId()+' Message: '+err.getMessage()+'\n';
                }
            }
        }
        if(String.isNotBlank(strError)){
            if(!bThrowException){
                ErrorLogger.suppressException = true;
            }
            ErrorLogger.logError(strError);
            if(!bThrowException){
                ErrorLogger.suppressException = false;
            }
        }
    }

    @TestVisible
    private static void processDMLResults(Database.UpsertResult[] lstUpsertResult, Boolean bThrowException){
        String strError = '';
        for(Database.UpsertResult aResult : lstUpsertResult){
            if(aResult.isSuccess() == false){
                for (Database.Error err : aResult.getErrors()){
                    strError += 'Error during a DML. Record id: '+aResult.getId()+' Message: '+err.getMessage()+'\n';
                }
            }
        }
        if(String.isNotBlank(strError)){
            if(!bThrowException){
                ErrorLogger.suppressException = true;
            }
            ErrorLogger.logError(strError);
            if(!bThrowException){
                ErrorLogger.suppressException = false;
            }
        }
    }

}