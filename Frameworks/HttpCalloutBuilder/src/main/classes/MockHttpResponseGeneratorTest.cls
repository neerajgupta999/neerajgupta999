@IsTest
private class MockHttpResponseGeneratorTest {
    @IsTest
    static void testRespond() {
        // Create a mock HttpRequest
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://example.com/api');
        request.setMethod('GET');

        // Create a mock HttpResponse
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setBody('{"message":"Hello, World!"}');

        // Create a new instance of MockHttpResponseGenerator with the mock response
        MockHttpResponseGenerator mockGenerator = new MockHttpResponseGenerator(mockResponse);

        // Call the respond() method and verify the response
        HttpResponse response = mockGenerator.respond(request);
        Assert.isTrue(200 == response.getStatusCode(), 'Expected Response status code to be 200');
        Assert.isTrue('OK' == response.getStatus(), 'Expected Response status should be OK');
        Assert.isTrue('{"message":"Hello, World!"}' == response.getBody(), 'Expected Response body should be {"message":"Hello, World!"}');
    }
}