public with sharing class MSP_TradeHoldRequestResource extends MSP_APIClientBase {
    private String accountId;
    private String accountNumber;
    private String custodian;
    private Boolean isTradeHold;
    private String tradeHoldNote;
    
    private MSP_TradeHoldRequestResource() {

    }
    public MSP_TradeHoldRequestResource(Id householdId) {
        this.householdId = householdId;
        
    }

    public MSP_TradeHoldRequestResource setTradehold(boolean isTradehold) {
        this.isTradeHold = isTradehold;
        return this;
    }

    public MSP_TradeHoldRequestResource setTradeholdNote(String tradeHoldNote) {
        this.tradeHoldNote = tradeHoldNote;
        return this;
    }
    
    /*public MSP_TradeHoldRequestResource setHouseholdId(Id householdId) {
        this.householdId = householdId;
        return this;
    }*/

    public MSP_TradeHoldRequestResource setAccountId(Id accountId) {
        this.accountId = accountId;
        return this;
    }

    public MSP_TradeHoldRequestResource setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
        return this;
    }

    public MSP_TradeHoldRequestResource setCustodian(String custodian) {
        this.custodian = custodian;
        return this;
    }

    private string requestBody() {
        if (this.isTradeHold != null) {
            TradeHoldRequestDto requestDto = new TradeHoldRequestDto();
            requestDto.isTradeHold = this.isTradeHold;
            requestDto.tradeHoldNote = this.tradeHoldNote != null ? this.tradeHoldNote : (this.isTradeHold ? 'Adding Trade Hold' : 'Removing Trade Hold');
            return JSON.serialize(requestDto);
        } 
        throw new MSP_APIClientBase.MSPAPIClientException('Missing required callout parameters.');
    }

    private class TradeHoldRequestDto{
        boolean isTradeHold;
        String tradeHoldNote;
    }

    
    //@TestVisible
    public Class MSP_GetTradeHoldResponseResource {
        public String custodianAccountNumber;
        public boolean isTradeHold;
        public String tradeHoldNote;
    }
	
    //@TestVisible
    public Class MSP_PutTradeHoldResponseResource {
        public String custodianAccountNumber;
        public boolean isTradeHold;
        public String tradeHoldNote;
    }
    /*
    private String getAdvisorToken() {
        if (householdId != null) {
            return this.getAdvisorTrustedContextByHousehold(this.householdId);
        }
        throw new MSP_APIClientBase.MSPAPIClientException('Not enough details to generate token.');
    }*/
    
    
    public HttpCalloutBuilder.HttpCalloutResponse getTradeHold() {
        String strEndPoint = this.baseURL() + 'v1/accounts/';
        strEndPoint += this.getCustodianCompositeAccountNumber(custodian, accountNumber);
        strEndPoint += '/trade-hold';

        HttpCalloutBuilder req = this.getBaseRequest(strEndPoint, householdId, null);

        //MSP_GetTradeHoldResponseResource response = (MSP_GetTradeHoldResponseResource) this.doGet(req, MSP_GetTradeHoldResponseResource.class);
        HttpCalloutBuilder.HttpCalloutResponse response = this.doGet(req, MSP_GetTradeHoldResponseResource.class);
        
        return response;

        /*if (response.isSuccess) {
            MSP_GetTradeHoldResponseResource responseObj = (MSP_GetTradeHoldResponseResource)response.parsedResponse;
            return responseObj.isTradeHold;
        } else {
            throw new MSP_APIClientBase.MSPAPIClientException(response.response.getBody());
        }*/
    }

    public  HttpCalloutBuilder.HttpCalloutResponse sendTradeHoldRequest() {
        String strEndPoint = this.baseURL() + 'v1/accounts/';
        strEndPoint += this.getCustodianCompositeAccountNumber(custodian, accountNumber);
        strEndPoint += '/trade-hold';
        HttpCalloutBuilder req = this.getBaseRequest(strEndPoint, householdId, null);
        req.setBody(this.requestBody());

        HttpCalloutBuilder.HttpCalloutResponse response = this.doPUT(req, MSP_PutTradeHoldResponseResource.class);
        return response;

        /*if (response.isSuccess) {
            MSP_PutTradeHoldResponseResource responseObj = (MSP_PutTradeHoldResponseResource)response.parsedResponse;
            return responseObj.isTradeHold;
        } else {
            throw new MSP_APIClientBase.MSPAPIClientException(response.response.getBody());
        }*/
    }
    
}