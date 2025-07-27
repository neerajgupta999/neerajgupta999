public with sharing class MSP_DeeplinkRequestResource extends MSP_APIClientBase {
    private String accountId{get;set;}
    private String viewType  {get; private set;}
    private String accountNumber;
    private String custodian;
    
    public MSP_DeeplinkRequestResource()
    {
        
    }
    
    public MSP_DeeplinkRequestResource(Id householdId, Id plannerId){
        this.householdId = householdId;
        this.plannerId = plannerId;
    }
    
    public MSP_DeeplinkRequestResource setViewType(String viewType) {
        this.viewType = viewType;
        return this;
    }

    /*public MSP_DeeplinkRequestResource setHouseholdId(Id householdId) {
        this.householdId = householdId;
        return this;
    }*/

    public MSP_DeeplinkRequestResource setAccountId(String accountId) {
        this.accountId = accountId;
        return this;
    }

    public MSP_DeeplinkRequestResource setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
        return this;
    } 

    public MSP_DeeplinkRequestResource setCustodian(String custodian) {
        this.custodian = custodian;
        return this;
    }

    /*public MSP_DeeplinkRequestResource setPlannerId(String plannerId) {
        this.plannerId = plannerId;
        return this;
    }*/

    
    public Class MSP_DeeplinkResponseResource {
        public string url;
    }

    @TestVisible
    private String endpoint;

    public HttpCalloutBuilder.HttpCalloutResponse getDeepLinks() {
        endpoint = this.baseURL() + 'v1/deeplinks/orion?viewType=' + this.viewType;
        if (custodian != null && accountNumber != null) {
            endpoint += '&custodianCompositeAccountNumber=' + this.getCustodianCompositeAccountNumber(custodian, accountNumber);
        }
        HttpCalloutBuilder req = this.getBaseRequest(endpoint, householdId, plannerId);
        return doGet(req, MSP_DeeplinkResponseResource.class);
    }
}