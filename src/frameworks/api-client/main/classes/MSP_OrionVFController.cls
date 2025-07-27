public with sharing class MSP_OrionVFController {

    public string url{get;set;}    
    public String recordId;
    private string finAccountId = null;
    private String householdId = null;
    private String plannerId = null;
    private String accountNumber = null;
    private String custodian = null;

    public MSP_OrionVFController() {
        Map<String, String> mapParameters = System.currentPageReference().getParameters();
        System.debug(LoggingLevel.DEBUG, 'mapParameters : ' + mapParameters);
        this.recordId = mapParameters.containsKey('id') ? mapParameters.get('id') : null;        
    }

    public void getDashboardLinkHousehold() {
        this.householdId = this.recordId;
        this.url = getOrionDashboardLink('household_dashboard');
    }

    public void getDashboardLinkPlanner() {
        this.plannerId = this.recordId == null ? UserInfo.getUserId() : this.recordId;
        this.url = getOrionDashboardLink('planner_dashboard');
    }

    public void getDashboardLinkRMD() {
        this.plannerId = this.recordId == null ? UserInfo.getUserId() : this.recordId;
        this.url = getOrionDashboardLink('planner_rmd_dashboard');
    }

    public void getDashboardLinkFinAccount() {
        this.finAccountId = this.recordId;
        if(this.finAccountId != null) {
            List<FinServ__FinancialAccount__c> lstFA = [SELECT Custodian__c, FinServ__Household__r.Assigned_Adviser__c, FinServ__FinancialAccountNumber__c  
                                                        FROM FinServ__FinancialAccount__c 
                                                        WHERE id = :this.finAccountId 
                                                        WITH SECURITY_ENFORCED];
            if (lstFA.isEmpty()) {
                throw new MSP_APIClientBase.MSPAPIClientException('Incorrect financial Account Id is passed.' + this.finAccountId);
            }
            this.plannerId = lstFA.get(0).FinServ__Household__r.Assigned_Adviser__c;
            this.householdId = lstFA.get(0).FinServ__Household__c;
            this.custodian = lstFA.get(0).Custodian__c;
            this.accountNumber = lstFA.get(0).FinServ__FinancialAccountNumber__c;
        }
        this.url = getOrionDashboardLink('account_dashboard');
    }

    private String getOrionDashboardLink(String viewType) {
        try {
            HttpCalloutBuilder.HttpCalloutResponse response = new MSP_DeeplinkRequestResource(householdId,plannerId)
                                                                .setViewType(viewType)
                                                                .setAccountId(finAccountId)
                                                                .setAccountNumber(accountNumber)
                                                                .setCustodian(custodian)
                                                                .getDeepLinks(); 
            if (response.isSuccess) {
                return ((MSP_DeeplinkRequestResource.MSP_DeeplinkResponseResource)response.parsedResponse).url;
            } else {
                ApexPages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'API call Failed: ' +  response.response.getBody()));
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'Error Occured: ' +  ex.getMessage()));
        }
        return null;
    }
}