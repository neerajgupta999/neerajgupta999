@isTest
public with sharing class MSP_TerminateMockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a new HTTPResponse
        if (req.getMethod() == 'POST' || req.getMethod() == 'GET' || req.getMethod() == 'PUT' || req.getMethod() == 'DELETE') {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, String> bodyMap = new Map<String, String>();    
            bodyMap.put('status', 'SUCCEEDED');
            bodyMap.put('token', '5128859e-9db3-4cf9-b6d9-f96ee1259531');
            res.setStatusCode(200);
            res.setBody(JSON.serialize(bodyMap));
            return res;
        }

        return null;
    }
}