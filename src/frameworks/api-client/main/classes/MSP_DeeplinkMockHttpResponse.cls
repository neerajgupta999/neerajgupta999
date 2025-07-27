// Mock HTTP callout response
@isTest
global class MSP_DeeplinkMockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        MSP_DeeplinkRequestResource.MSP_DeeplinkResponseResource resp = new MSP_DeeplinkRequestResource.MSP_DeeplinkResponseResource();
        resp.url = 'https://example.com/deeplink';
        res.setBody(JSON.serialize(resp));
        return res;
    }
}