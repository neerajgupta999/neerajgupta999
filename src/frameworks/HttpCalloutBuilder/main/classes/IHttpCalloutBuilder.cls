/**
 * @description       : Defines the interface for an HTTP callout builder.
 * @last modified on  : 05-05-2023
 * @last modified by  : Neeraj Gupta
**/
public interface IHttpCalloutBuilder { 
    IHttpCalloutBuilder setEndpoint(String endpoint);
    IHttpCalloutBuilder setBody(String body);
    IHttpCalloutBuilder setTimeout(Integer timeout);
    IHttpCalloutBuilder setHeader(String key, String value);
    IHttpCalloutBuilder setMethod(String method);
    IHttpCalloutBuilder setResponseType(Type responseType);
    HttpCalloutBuilder.HttpCalloutResponse send();
}