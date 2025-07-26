@isTest
/**
 * @description       : Represents a test class for HttpCalloutBuilder.
 * @last modified on  : 05-05-2023
 * @last modified by  : Neeraj Gupta
 * @isTest            : Indicates that this is a test class.
**/
private class HttpCalloutBuilderTest {
    @isTest
    static void testSend_SuccessfulCallout() {
        
        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200); 
        mockResponse.setBody('{"success": true}');
        
        // Create a mock HTTP instance and mock the send method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Create an instance of HttpCalloutBuilder
        HttpCalloutBuilder builder = new HttpCalloutBuilder();
        builder.setEndpoint('https://example.com/api')  // Set the request endpoint
                .setBody('Hello World!')
                .setBody(String.Class, '{"request": true}')
                .setTimeout(2000)
                .setHeader('Content-Type', 'application/json')
                .setMethod('Post')
                .setResponseType(MyResponseClass.class);    // Set the response type
        
        // Send the request
        HttpCalloutBuilder.HttpCalloutResponse response = builder.send();
        
        // Verify the response
        Assert.isTrue(response.isSuccess, 'Response should be successful');
        Assert.isTrue(response.calloutException == null, 'No callout exception should occur');
        Assert.isTrue(response.parsedResponse != null, 'Parsed response should not be null');
        Assert.isTrue(true == ((MyResponseClass)response.parsedResponse).success, 'Parsed response should have the correct success value');
    }
    
    @isTest
    static void testSend_FailedCallout() {
        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('Internal Server Error');
        
        // Create a mock HTTP instance and mock the send method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Create an instance of HttpCalloutBuilder
        HttpCalloutBuilder builder = new HttpCalloutBuilder();
        
        // Set the request endpoint
        builder.setEndpoint('https://example.com/api');
        
        // Send the request
        HttpCalloutBuilder.HttpCalloutResponse response = builder.send();
        
        // Verify the response
        Assert.isFalse(response.isSuccess, 'Response should not be successful');
        Assert.isTrue(response.calloutException != null, 'Callout exception should occur');
        Assert.isTrue('Not a 200 Response' == response.calloutException.getMessage(), 'Callout exception message should be correct');
        Assert.isTrue(response.parsedResponse == null, 'Parsed response should be null');
    }
    
    private class MyResponseClass {
        public Boolean success { get; set; }
    }
}