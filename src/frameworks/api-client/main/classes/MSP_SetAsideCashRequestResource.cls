public with sharing class MSP_SetAsideCashRequestResource extends MSP_APIClientBase {
    
    //Request Parameters 
    public virtual class requestParamBase {
        private String custodian;
        private String accountNumber;
        private String householdId;
        public requestParamBase setCustodian(String custodian) {
            this.custodian = custodian;
            return this;
        }

        public requestParamBase setAccountNumber(String accountNumber) {
            this.accountNumber = accountNumber;
            return this;
        }

        public requestParamBase setHouseholdId(String householdId) {
            this.householdId = householdId;
            return this;
        }
    }
    public class createSetAsideCashRequestParm extends requestParamBase {
        private SetAsideCashRequestDto body;
        public createSetAsideCashRequestParm setbody(SetAsideCashRequestDto body) {
            this.body = body;
            return this;
        }
    }

    public class getSetAsideCashRequestParm extends requestParamBase {
        private Integer setAsideCashId;
        public getSetAsideCashRequestParm setCashAsideId(Integer setAsideCashId) {
            this.setAsideCashId = setAsideCashId;
            return this;
        }
    } 

    public class deleteSetAsideCashRequestParm extends requestParamBase {
        private Integer setAsideCashId;
        public deleteSetAsideCashRequestParm setCashAsideId(Integer setAsideCashId) {
            this.setAsideCashId = setAsideCashId;
            return this;
        }
    }

    //Request Response DTO's
    public class SetAsideCashRequestDto {
        public Decimal federalWithholdingPercent;
        public String fundSource;
        public Decimal grossAmount;
        public String note;
        public Decimal stateWithholdingPercent;
    }

    public class SetAsideCashCreateResponsetDto {
        public String custodianCompositeAccountNumber;
        public Decimal federalWithholdingPercent;
        public String fundSource;
        public Decimal grossAmount;
        public Integer id;
        public String note;
        public Decimal stateWithholdingPercent;
        //HttpCalloutBuilder.HttpCalloutResponse response;
    }
    
    public class SetAsideCashGetResponseDto{
        String custodianCompositeAccountNumber;
        integer id;
        String status;
    }

    public class SetAsideCashDeleteResponseDto{
        public String message;
    }

    //API Calls
    public HttpCalloutBuilder.HttpCalloutResponse createSetAsideCashRequest(createSetAsideCashRequestParm reqParam) {
        String endpoint = this.baseURL() + 'v1/accounts/' + this.getCustodianCompositeAccountNumber(reqParam.custodian, reqParam.accountNumber) + '/set-aside-cash';
        HttpCalloutBuilder req = this.getBaseRequest(endpoint, reqParam.householdId, null);
        req.setBody(JSON.serialize(reqParam.body));
        HttpCalloutBuilder.HttpCalloutResponse responseObj = this.doPost(req, SetAsideCashCreateResponsetDto.class);
        return responseObj;
    }

    public HttpCalloutBuilder.HttpCalloutResponse getSetAsideCashRequest(getSetAsideCashRequestParm reqParam) {
        if (reqParam.setAsideCashId == null) {
            throw new MSP_APIClientBase.MSPAPIClientException('Missing Set Aside cash Id.');
        }
        String endpoint = this.baseURL() + 'v1/accounts/' + this.getCustodianCompositeAccountNumber(reqParam.custodian, reqParam.accountNumber) + '/set-aside-cash/' + reqParam.setAsideCashId;
        HttpCalloutBuilder req = this.getBaseRequest(endpoint, reqParam.householdId, null);
        return this.doGet(req, SetAsideCashGetResponseDto.class);   
    }

    public HttpCalloutBuilder.HttpCalloutResponse deleteSetAsideCashRequest(deleteSetAsideCashRequestParm reqParam) {
        if (reqParam.setAsideCashId == null) {
            throw new MSP_APIClientBase.MSPAPIClientException('Missing Set Aside cash Id.');
        }
        String endpoint = this.baseURL() + 'v1/accounts/' + this.getCustodianCompositeAccountNumber(reqParam.custodian, reqParam.accountNumber) + '/set-aside-cash/' + reqParam.setAsideCashId;
        HttpCalloutBuilder req = this.getBaseRequest(endpoint, reqParam.householdId, null);
        return this.doDelete(req, SetAsideCashDeleteResponseDto.class);   
    }     
}