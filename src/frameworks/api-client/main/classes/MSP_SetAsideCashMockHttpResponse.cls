@isTest
public with sharing class MSP_SetAsideCashMockHttpResponse  implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        if (req.getMethod() == 'POST') {
            res.setBody('{"custodianCompositeAccountNumber":"string","federalWithholdingPercent":0,"fundSource":"MODEL","grossAmount":0,"id":10,"note":"string","stateWithholdingPercent":0}');
            res.setStatusCode(200);
        }
        if (req.getMethod() == 'GET') {
            res.setBody('{"custodianCompositeAccountNumber":"string","id":10,"status":"IN_PROGRESS"}');
            res.setStatusCode(200);
        }
        if (req.getMethod() == 'DELETE') {
            res.setBody('{"message":"Deleted"}');
            res.setStatusCode(200);
        }
        return res;
    }
}