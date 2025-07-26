/*
IAddressValidator fedexServiceInstance = new AddressServiceManager().getAddressService('FedexAddressValidatorService');
String token = fedexServiceInstance.getToken(null, null);
*/
/*
HttpRequest req = new HttpRequest(); 
req.setEndpoint('callout:FedexSandboxOauth'); 
req.setMethod('POST'); 
Http http = new Http(); 
HTTPResponse res = http.send(req); 
System.debug('>>>>>>>>>>>>>>>' + res.getBody());
*/ 
/*
Map<String, String> params = new Map<String, String>();
params.put('street_0','11620 County Road L');
params.put('street_1','');
params.put('zip', '43615');
params.put('city', 'Toledo');
params.put('region_code', 'OH');
params.put('country', 'US');*/
IAddressValidator fedexServiceInstance = new AddressServiceManager().getAddressService('FedexAddressValidatorService');
fedexServiceInstance.getAccessToken();
/*
//Map<String, Object> response = fedexServiceInstance.getAddressValidation(params);
Cache.OrgPartition ecompluginCache = Cache.Org.getPartition('local.ecompluginCache');
ecompluginCache.put('accessToken', 'Hello', 3500);
System.debug(token + '>>>>Token>>>>' + ecompluginCache.get('accessToken'));*/