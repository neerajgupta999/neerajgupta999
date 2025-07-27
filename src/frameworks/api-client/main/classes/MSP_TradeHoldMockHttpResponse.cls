// Mock HTTP callout response
@isTest
global class MSP_TradeHoldMockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        MSP_TradeHoldRequestResource.MSP_PutTradeHoldResponseResource resp = new MSP_TradeHoldRequestResource.MSP_PutTradeHoldResponseResource();
        resp.custodianAccountNumber = '7788991122';
        resp.isTradeHold = true;
        resp.tradeHoldNote = 'test Note';
        res.setBody(JSON.serialize(resp));
        return res;
    }
}