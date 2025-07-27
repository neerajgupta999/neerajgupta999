public virtual class MSP_APIClientBase {

    protected Id householdId;
    protected Id plannerId;

    public String getAdvisorTrustedContext(Id plannerId) {
        List<User> lstPlannerUser = UserDao.getUsersByIds(new Set<Id> {plannerId});
        if (!lstPlannerUser.isEmpty()) {
            return getToken(lstPlannerUser.get(0), new JWTUtil.Client());
        }
        throw new MSPAPIClientException('Unable to generate token, Invalid Request.');
    }

    public String getAdvisorTrustedContextByHousehold(Id householdId) {
        if(String.isNotblank(householdId)) { 
            List<Account> householdList = [SELECT fe_external_id__c, assigned_Adviser__c, assigned_Adviser__r.Id, assigned_Adviser__r.SSO_username__c, 
                                 Assigned_Adviser__r.Email FROM Account WHERE id = :householdId 
                                 AND RecordType.DeveloperName =: RecordTypeUtil.ACCOUNT_TYPE_HOUSEHOLD_DEVELOPERNAME];
            if(!householdList.isEmpty()){
                JWTUtil.Client additionalClaim = new JWTUtil.Client();
                additionalClaim.clientType = 'Retail';
                additionalClaim.householdId = householdList[0].fe_external_id__c;
                additionalClaim.salesforceAccountId = householdId;
                return getToken(householdList[0].assigned_Adviser__r, additionalClaim);
            }
            throw new MSPAPIClientException('Unable to generate token, hosuehold not found for given household id.');
        }
        throw new MSPAPIClientException('Unable to generate token, hosuehold id is blank');
    }

    public String baseURL () {
        return 'callout:FeApiGatewayUrl' + (Util.isProd() ? 'Prod' : 'Sandbox') + '/managed-solutions-platform/';
    }

    public String getCustodianCompositeAccountNumber(String custodian, String accountNumber) {
        //Implementation pending... 
        //Albert mentioned we have custom metadata confirm and update logic here. 
        //custodian = (custodian.toLowerCase().contains('schwab')) ? 'schwabinst' : custodian; //schwabinst
        custodian = CustomMetadataUtil.getCustodianRkId(custodian);
        return custodian + '::' + accountNumber;
    }
    
    public HttpCalloutBuilder getBaseRequest(String strEndPoint, Id householdId, Id plannerId) {
        this.householdId = householdId;
        this.plannerId = plannerId;
        System.debug('EFELOGS:: householdId in getBaseRequest: '+householdId);
        return new HttpCalloutBuilder()
                .setEndpoint(strEndPoint)
                .setHeader(Constant.HEADER_CONTENT_TYPE, Constant.HEADER_CONTENT_TYPE_VAL)
                .setTimeout(120000)
                .setHeader(Constant.HEADER_AUTHORIZATION, getTokenForRequest());
    }

    public HttpCalloutBuilder.HttpCalloutResponse doPost(HttpCalloutBuilder req, Type responseType) {
        req.setMethod('POST');
        return sendRequest(req, responseType);
    }

    public HttpCalloutBuilder.HttpCalloutResponse doGet(HttpCalloutBuilder req, Type responseType) {
        req.setMethod('GET');
        return sendRequest(req, responseType);
    }

    public HttpCalloutBuilder.HttpCalloutResponse doPut(HttpCalloutBuilder req, Type responseType) {
        req.setMethod('PUT');
        return sendRequest(req, responseType);
    }

    public HttpCalloutBuilder.HttpCalloutResponse doDelete(HttpCalloutBuilder req, Type responseType) {
        req.setMethod('DELETE');
        return sendRequest(req, responseType);
    }

    @TestVisible
    private HttpCalloutBuilder.HttpCalloutResponse sendRequest(HttpCalloutBuilder req, Type responseType) {
        if (responseType != null) {
            req.setResponseType(responseType);
        }
        
        HttpCalloutBuilder.HttpCalloutResponse response = req.send();
        return response;
        /*
        if (response.isSuccess) {
            return response.parsedResponse;
        } else if (response.response != null) {
            throw new MSP_APIClientBase.MSPAPIClientException(response.response.getBody());
        } else {
            throw new MSP_APIClientBase.MSPAPIClientException('Unknown Exception occured. Please contact System Administrator.' + response);
        }*/
    }

    @TestVisible
    private String getTokenForRequest() {
        if (householdId == null && plannerId == null) {
            throw new MSPAPIClientException('PlannerId or HouseholdId is required to generate token.');
        }
        if (this.householdId != null) {
            String token = this.getAdvisorTrustedContextByHousehold(householdId);
            System.debug('EFELOGS:: Token in getTokenForRequest: '+token);
            return token;
        }
        return this.getAdvisorTrustedContext(plannerId);
    }

    @TestVisible
    private String getToken(User planner, JWTUtil.Client additionalClaims) {
        if (planner == null) {
            throw new MSPAPIClientException('Unable to get Token. No planner provided.');
        }
        String plannerSSOUserName = planner.SSO_username__c;
        String plannerEmail = planner.Email;

        if (String.isBlank(plannerEmail)) {
            throw new MSPAPIClientException('Unable to get Token. Planner Email is not provided, ' + plannerEmail);
        }
        if (String.isBlank(plannerSSOUserName)) {
            throw new MSPAPIClientException('Unable to get Token. Planner SSO UserName is not provided, ' + plannerSSOUserName);
        }
        return JWTUtil.getSessionTokenFromIdentityWClient(additionalClaims, plannerSSOUserName, PlannerEmail);   
    }

    public class MSPAPIClientException extends Exception{}
    
     /// added after here: Todd

    private static final Map<String, String> DELIMITERS = new Map<String, String> { 'csv' => ',', 'ssv' => ' ','tsv' => '\t','pipes' => '|'};
        
    public class Param 
    {
        private String name, value;
        public Param(String name, String value) 
        {
          this.name = name;
          this.value = value;
        }
        public override String toString() 
        {
          return EncodingUtil.urlEncode(name, 'UTF-8') + '='+ EncodingUtil.urlEncode(value, 'UTF-8');
        }
    }
    
    public List<Param> makeParams(String name, List<Object> values) 
    {
        List<Param> pairs = new List<Param>();
        for (Object value : new List<Object>(values)) {
            pairs.add(new Param(name, String.valueOf(value)));
        }
        return pairs;
    }

    public List<Param> makeParam(String name, List<Object> values, String format) 
    {
        List<Param> pairs = new List<Param>();
        if (values != null) {
            String delimiter = DELIMITERS.get(format);
            pairs.add(new Param(name, String.join(values, delimiter)));
        }
        return pairs;
    }
    
    public List<Param> makeParam(String name, Object value) 
    {
        List<Param> pairs = new List<Param>();
        if (value != null) {
            pairs.add(new Param(name, String.valueOf(value)));
        }
        return pairs;
    }

    public interface MappedProperties 
    {
        Map<String, String> getPropertyMappings();
    }
    
    @TestVisible
    protected virtual String toPath(String path, Map<String, Object> params) 
    {
        String formatted = path;
        for(String key : params.keySet()) 
        {
            formatted = formatted.replace('{' + key + '}', EncodingUtil.urlEncode(String.valueOf(params.get(key)), 'UTF-8'));
        }
        return formatted;
    }
    
    @TestVisible
    protected virtual String toEndpoint(String path, Map<String, Object> params,List<Param> queryParams) 
    {
        String query = '?' + paramsToString(queryParams);
        return this.baseURL() + toPath(path, params) + query.removeEnd('?') ;
    }

    
    @TestVisible
    public String paramsToString(List<Param> params) 
    {
        String s = '';
        for (Param p : params) 
        {
            s += '&' + p;
        }
        return s.removeStart('&');
    }
    
    protected virtual void assertNotNull(Object required, String parameterName) 
    {
        if (required == null) 
        {
            Exception e = new NullPointerException();
            e.setMessage('Argument cannot be null: ' + parameterName);
            throw e;
        }

    }
    
    public MSP_APIClientBase setHouseholdId(Id householdId) 
    {
        this.householdId = householdId;
        System.debug('EFELOGS:: householdID'+this.householdId);
        return this;
    }
    
    public MSP_APIClientBase setPlannerId(String plannerId) 
    {
        this.plannerId = plannerId;
        System.debug('EFELOGS:: plannerId'+this.plannerId);
        return this;
    }
    /*
    public MSP_APIClientBase setAccountId(Id finAccountId) {
        this.finAccountId = finAccountId;
        return this;
    }
    
    public MSP_APIClientBase setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
        return this;
    }
    
    public MSP_APIClientBase setCustodian(String custodian) {
        this.custodian = custodian;
        return this;
    }
    
    public MSP_APIClientBase setTradehold(boolean isTradehold) {
        this.isTradeHold = isTradehold;
        return this;
    }

    public MSP_APIClientBase setTradeholdNote(String tradeHoldNote) {
        this.tradeHoldNote = tradeHoldNote;
        return this;
    }
    
    public HttpCalloutBuilder.HttpCalloutResponse sendTradeHoldRequest(){
        return null;
    }*/
}