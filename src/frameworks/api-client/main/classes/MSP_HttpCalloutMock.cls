@isTest
public with sharing class MSP_HttpCalloutMock implements HttpCalloutMock {
    public class MSP_HttpCalloutMockException extends Exception {} 
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response;
        if (req.getEndpoint().contains('/auth/v1/token')) {
            response = new MSP_TokenMockHttpResponse().respond(req);
        } 
        
        if (req.getEndpoint().contains('/v1/workflows/terminate')) {
            response = new MSP_TerminateMockHttpResponse().respond(req);   
        }
        if (req.getEndpoint().contains('/withdrawals')) {
            response = new MSP_TerminateMockHttpResponse().respond(req);   
        }
        if (response == null) {
            throw new MSP_HttpCalloutMockException('Unable to find Mock Response for Test. Endpoint: ' + req.getEndpoint() );
        }

        return response;
    }
}