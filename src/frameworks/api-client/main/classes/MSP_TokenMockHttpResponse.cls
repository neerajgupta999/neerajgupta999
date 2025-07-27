public with sharing class MSP_TokenMockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('sessionToken', '12345');
        res.setBody(JSON.serialize(bodyMap));
        res.setStatusCode(200);
        return res;
    }
}