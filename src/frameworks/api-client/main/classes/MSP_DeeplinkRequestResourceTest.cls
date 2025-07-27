@isTest
private class MSP_DeeplinkRequestResourceTest {
    @isTest
    static void testGetDeepLinksHousehold() {
        // Mock the HTTP callout response
        HttpCalloutMock mock = new MSP_DeeplinkMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Account household = [SELECT Id, Name, Assigned_Adviser__c, Assigned_Adviser__r.Name FROM Account WHERE recordtype.name = 'Household' limit 1];
        Id userId = [Select Id from User Where isActive = true and SSO_username__c != null Limit 1].get(0).Id;

        // Create a test instance of MSP_DeeplinkRequestResource
        MSP_DeeplinkRequestResource deeplinkResource = new MSP_DeeplinkRequestResource(household?.Id,userId)
            .setViewType('someViewType');
            //.setHouseholdId(household?.Id);
            //.setPlannerId([Select Id from User Where isActive = true Limit 1].get(0).Id);

        Test.startTest();
        // Call the method to be tested
        String deeplinkUrl =  ((MSP_DeeplinkRequestResource.MSP_DeeplinkResponseResource)deeplinkResource.getDeepLinks().parsedResponse).url;
        Test.stopTest();

        //Assert that generated request url matches to mock endpoint.
        System.assertEquals(deeplinkResource.baseURL() + 'v1/deeplinks/orion?viewType=someViewType', deeplinkResource.endpoint);

        // Assert that the expected URL is returned
        System.assertEquals('https://example.com/deeplink', deeplinkUrl);
    }

    @isTest
    static void testGetDeepLinksAccount() {
        // Mock the HTTP callout response
        HttpCalloutMock mock = new MSP_DeeplinkMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);
        Id userId = [Select Id from User Where isActive = true and SSO_username__c != null Limit 1].get(0).Id;

        // Create a test instance of MSP_DeeplinkRequestResource
        MSP_DeeplinkRequestResource deeplinkResource = new MSP_DeeplinkRequestResource(null, userId)
            .setViewType('someViewType')
            .setAccountNumber('123456')
            .setCustodian('Charles Schwab');
            //.setPlannerId([Select Id from User Where isActive = true and SSO_username__c != null Limit 1].get(0).Id);

        Test.startTest();
        // Call the method to be tested
        String deeplinkUrl =  ((MSP_DeeplinkRequestResource.MSP_DeeplinkResponseResource)deeplinkResource.getDeepLinks().parsedResponse).url;
        Test.stopTest();

        //Assert that generated request url matches to mock endpoint.
        System.assertEquals(deeplinkResource.baseURL() + 'v1/deeplinks/orion?viewType=someViewType&custodianCompositeAccountNumber=schwabinst::123456', deeplinkResource.endpoint);

        // Assert that the expected URL is returned
        System.assertEquals('https://example.com/deeplink', deeplinkUrl);
    }



    private static final String USER_ALIAS = 'Planner';
    
    // Create Test Data
    @testSetup
    private static void insertPlanner(){
        User planner = CreateTestRecordUtils.createTestUser('Field Advisor Dragonfly1', USER_ALIAS ,false);
        planner.email = 'MSP_APIClientBaseTest@fngn.com';
        planner.SSO_username__c = USER_ALIAS;
        insert planner;
        
        createData();
    }

   @future
    private static void createData(){
        User planner = [SELECT Id FROM User WHERE Alias =: USER_ALIAS LIMIT 1];
        Account primaryAccount = new Account(FirstName = 'Primary',LastName = 'Account',Email__c='primary@test.com',Assigned_Adviser__c= planner.Id);
        insert primaryAccount;
    }

}