/**
 * @description       : Generates a mock HTTP response for testing.
 * @last modified on  : 05-05-2023
 * @last modified by  : Neeraj Gupta
**/
public class MockHttpResponseGenerator implements HttpCalloutMock {
    private HttpResponse mockResponse;

    //Constructs a MockHttpResponseGenerator with the specified mock response.
    public MockHttpResponseGenerator(HttpResponse mockResponse) {
        this.mockResponse = mockResponse;
    }

    //Responds to the HTTP callout with the mock response.
    public HttpResponse respond(HttpRequest request) {
        return this.mockResponse;
    }
}