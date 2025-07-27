@isTest(isParallel=false)
private class MSP_APIClientBaseTest {
    private static final String USER_ALIAS = 'Planner';
    
    // Create Test Data
    @testSetup
    private static void insertPlanner(){
        User planner = CreateTestRecordUtils.createTestUser('Field Advisor Dragonfly1', USER_ALIAS ,false);
        //planner.email = 'MSP_APIClientBaseTest@fngn.com';
        planner.SSO_username__c = USER_ALIAS;
        insert planner;
        
        createData();
    }

   @future
    private static void createData(){
        User planner = [SELECT Id FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
        Account primaryAccount = new Account(FirstName = 'Primary',LastName = 'Account',Email__c='primary@test.com',Assigned_Adviser__c= planner.Id);
        insert primaryAccount;
        Account coClientAccount = new Account(FirstName = 'CoClient',LastName = 'Account',Email__c='coclient@test.com',Assigned_Adviser__c= planner.Id);
        insert coClientAccount;
        Map<Id,Set<Id>> householdMap = HouseholdDao.getRelatedHouseholdIds(new Set<Id>{primaryAccount.Id});
        Account household = [SELECT Id, Name, Assigned_Adviser__c, Assigned_Adviser__r.Name FROM Account WHERE Id IN: householdMap.values()[0] limit 1];
        Contact primaryAccountContact = [Select Id, Name, Email FROM Contact WHERE AccountId =: primaryAccount.Id];
    }

    @isTest static void testGetAdvisorTrustedContext(){

        User planner = [SELECT Id, Email, SSO_username__c FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
     	
        Test.startTest(); 
        String token = mspClientBase.getAdvisorTrustedContext(planner.id); 
        Test.stopTest();
        
        Assert.isTrue(token != null, 'Expected Token');
    }

    @isTest static void testGetAdvisorTrustedContextByHousehold(){

        Account household = [SELECT Id, Name, Assigned_Adviser__c, Assigned_Adviser__r.Name FROM Account WHERE recordtype.name = 'Household' limit 1];
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
     	
        Test.startTest();
        String token = mspClientBase.getAdvisorTrustedContextByHousehold(household.id); 
        Test.stopTest();
        
        Assert.isTrue(token != null, 'Expected Token');
    }

    @isTest static void testGetTokenMissingEmail(){

        User planner = [SELECT Id, Email, SSO_username__c FROM User WHERE Alias =: USER_ALIAS LIMIT 1];

        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();

        Test.startTest();
            try{
                planner.Email = null;
                mspClientBase.getToken(planner, null); 
            } catch (Exception ex){
                Assert.isTrue(ex.getMessage().startsWith('Unable to get Token. Planner Email is not provided'), 'Error Message is not correct');
            }        
        Test.stopTest();
    }

    @isTest static void testGetTokenMissingSSOUserName(){

        User planner = [SELECT Id, Email, SSO_username__c FROM User WHERE Alias =: USER_ALIAS LIMIT 1];

        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();

        Test.startTest();
            try{
                planner.SSO_username__c = null;
                mspClientBase.getToken(planner, null); 
            } catch (Exception ex){
                Assert.isTrue(ex.getMessage().startsWith('Unable to get Token. Planner SSO UserName is not provided'), 'Error Message is not correct');
            }        
        Test.stopTest();
    }
    
    @isTest static void testGetBaseUrl() {
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
     	
        Test.startTest(); 
        String baseUrl = mspClientBase.baseURL(); 
        Test.stopTest();
        
        Assert.isTrue(baseUrl != null, 'Expected base Url');
    }
    @isTest static void testNegativeGetAdvisorTrustedContext(){

        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Test.startTest();
        try{
        	String token = mspClientBase.getAdvisorTrustedContext(null);
        }
        catch(Exception ex){
            Assert.isTrue(ex.getMessage() == 'Unable to generate token, Invalid Request.', 'Planner id sent null');
        }
        Test.stopTest();
    }
    
    @isTest static void testNegativeGetAdvisorTrustedContextByHousehold(){

        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Test.startTest();
        try{
        	String token = mspClientBase.getAdvisorTrustedContextByHousehold(null);
        }
        catch(Exception ex){
            Assert.isTrue(ex.getMessage() == 'Unable to generate token, hosuehold id is blank', 'Household id sent null');
        }
        Test.stopTest();
    }
    
    @isTest static void testNegativeGetAdvisorTrustedContextByWrongHousehold(){

        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Test.startTest();
        try{
        	String token = mspClientBase.getAdvisorTrustedContextByHousehold('001Ox000000000000T');
        }
        catch(Exception ex){
            Assert.isTrue(ex.getMessage() == 'Unable to generate token, hosuehold not found for given household id.', 'Wrong Household id sent' + ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest static void testNegativeGetToke(){

        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Test.startTest();
            try{
                mspClientBase.getToken(null, null); 
            } catch (Exception ex){
                Assert.isTrue(ex.getMessage().startsWith('Unable to get Token. No planner provided.'), 'Planner detail not available');
            }        
        Test.stopTest();
    }
    
    @isTest static void testGetCustodianCompositeAccountNumber(){

        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Test.startTest();
        String compositeAccNo = mspClientBase.getCustodianCompositeAccountNumber('Charles Schwab', '12345'); 
        Assert.isTrue(compositeAccNo == 'schwabinst::12345', 'composite acc no not returned correctly');
        Test.stopTest();
    }
    
    @isTest static void testGetBaseRequest(){
        
        User planner = [SELECT Id FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
		Account household = [SELECT Id, Name, Assigned_Adviser__c, Assigned_Adviser__r.Name FROM Account WHERE recordtype.name = 'Household' limit 1];       
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Test.startTest();
        HttpCalloutBuilder req = mspClientBase.getBaseRequest('strEndPoint', household.Id, planner.Id); 
        Assert.isTrue(req != null, 'request is null');
        HttpCalloutBuilder plannerReq = mspClientBase.getBaseRequest('strEndPoint', household.Id, planner.Id); 
        Assert.isTrue(plannerReq != null, 'request is null');
        Test.stopTest();
    }
    
    @isTest static void testDoPostDoGetDoPutDoDelete(){
        
        User planner = [SELECT Id FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
		Account household = [SELECT Id, Name, Assigned_Adviser__c, Assigned_Adviser__r.Name FROM Account WHERE recordtype.name = 'Household' limit 1];       
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Test.startTest();
        HttpCalloutBuilder req = mspClientBase.getBaseRequest('strEndPoint', household.Id, planner.Id); 
        
        // Create a mock response
        /*HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"success": true}');*/
        
        Test.setMock(HttpCalloutMock.class, new MSP_TokenMockHttpResponse());
        Object resDoPost = mspClientBase.doPost(req, HttpResponse.class); 
        Assert.isTrue(resDoPost != null, 'request is null');
        
        Object resDoGet = mspClientBase.doGet(req, HttpResponse.class); 
        Assert.isTrue(resDoGet != null, 'request is null');
        
        Object resDoPut = mspClientBase.doPut(req, HttpResponse.class); 
        Assert.isTrue(resDoPut != null, 'request is null');
        
        Object resDoDelete = mspClientBase.doDelete(req, HttpResponse.class); 
        Assert.isTrue(resDoDelete != null, 'request is null');
        Test.stopTest();
    }
    
    @isTest static void testMakeParams()
    {
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        List<String> lstStr = new List<String>();
        lstStr.add('testStr');
        Test.startTest();
        List<MSP_APIClientBase.Param> paramList = mspClientBase.makeParams('testParam',lstStr);
        Test.stopTest();
        Assert.isNotNull(paramList);
    }
    
    @isTest static void testMakeParam()
    {
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        List<String> lstStr = new List<String>();
        lstStr.add('testStr');
        Test.startTest();
        List<MSP_APIClientBase.Param> paramList = mspClientBase.makeParam('testParam',lstStr,'csv');
        Test.stopTest();
        Assert.isNotNull(paramList);
    }
    
    @isTest static void testMakeParamMethod()
    {
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Test.startTest();
        List<MSP_APIClientBase.Param> paramList = mspClientBase.makeParam('testParam','testValue');
        Test.stopTest();
        Assert.isNotNull(paramList);
    }
    
    @isTest static void testToPath()
    {
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Map<String, Object> params = new Map<String, Object>();
        params.put('testString','testObject');
        Test.startTest();
        String response = mspClientBase.toPath('testPath',params);
        Test.stopTest();
        Assert.isNotNull(response);
    }
    
    @isTest static void testEndPoint()
    {
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        Map<String, Object> params = new Map<String, Object>();
        params.put('testString','testObject');
        
        MSP_APIClientBase.Param p = new MSP_APIClientBase.Param('testName','testValue');
        List<MSP_APIClientBase.Param> queryParams = new List<MSP_APIClientBase.Param>();
        queryParams.add(p);
        
        Test.startTest();
        String response = mspClientBase.toEndPoint('testPath',params, queryParams);
        Test.stopTest();
        
        Assert.isNotNull(response);
    }
    
    @isTest static void testParamsToString()
    {
        MSP_APIClientBase mspClientBase = new MSP_APIClientBase();
        MSP_APIClientBase.Param p = new MSP_APIClientBase.Param('testName','testValue');
        List<MSP_APIClientBase.Param> queryParams = new List<MSP_APIClientBase.Param>();
        queryParams.add(p);
        
        Test.startTest();
        String response = mspClientBase.paramsToString(queryParams);
        Test.stopTest();
        
        Assert.isNotNull(response);

    }
    /*
    @isTest
    private static void testException(){
        Test.startTest();
        try{
            MSP_APIClientBase.assertNotNull('testObj', 'TestparameterName');
        } catch (Exception e){
            System.debug('Exception Triggerd');
        }
        Test.stopTest();
    }
*/
    /*
    @isTest static void testGetToke3(){
     	
        Test.startTest();
        JWTUtil.Client clientObj = new JWTUtil.Client();
        clientObj.envestnetClientId = '7654321';
        clientObj.householdId='cb6341ba-8da0-406b-b9ec-33d2dbc5afca';
        clientObj.clientType='Retail';
        clientObj.salesforceAccountId='0010v00000OT8GgAAL';
        String strAuthToken = JWTUtil.getSessionTokenFromIdentityWClient(ClientObj, 'envestnetPlannerName','tests@efe.com');
        Test.stopTest();
        
        System.assertEquals(JWTUtil.BEARER_TOKEN_TEST, strAuthToken);
    }*/
}