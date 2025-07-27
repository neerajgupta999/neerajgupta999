public with sharing class MSP_WorkflowsTerminateAPIClient extends MSP_APIClientBase{
    
    private static String endpointTerminate = 'v1/workflows/terminate';
    
    private MSP_WorkflowsTerminateAPIClient(){
        //do nt allow public instanciation 
        return; 
    }
    public MSP_WorkflowsTerminateAPIClient(Id householdId) {
        this.householdId = householdId;
    }
    
    public HttpCalloutBuilder.HttpCalloutResponse terminate(MSP_TerminationDto terminationRequest) {
        String endpoint = this.baseURL() + EndpointTerminate;
        HttpCalloutBuilder req = this.getBaseRequest(endpoint, this.householdId, null);
        req.setBody(JSON.serialize(terminationRequest));
        HttpCalloutBuilder.HttpCalloutResponse responseObj = this.doPost(req, MSP_WorkflowStatusDto.class);
        return responseObj;
    }

    public HttpCalloutBuilder.HttpCalloutResponse getStatus(String token) {
        String endpoint = this.baseURL() + EndpointTerminate + '/' + token;
        HttpCalloutBuilder req = this.getBaseRequest(endpoint, this.householdId, null);
        HttpCalloutBuilder.HttpCalloutResponse responseObj = this.doGet(req, MSP_WorkflowStatusDto.class);
        return responseObj;
    }
}