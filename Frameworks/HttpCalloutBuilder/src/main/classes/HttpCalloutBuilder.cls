/**
 * @description       : Represents a builder for making HTTP callouts.
 * @last modified on  : 05-05-2023
 * @last modified by  : Neeraj Gupta
**/
public with sharing class HttpCalloutBuilder implements IHttpCalloutBuilder {
    public class UnableToParseException extends Exception {}
    public class CalloutException extends Exception {}

    // Constants
    private static final String NOT_200_RESPONSE = 'Not a 200 Response';
    private static final String HTTP_CALL_FAILED_MESSAGE = 'Http call failed. Check Callout Exception for more details. Details: ';
    private static final String STACK_TRACE_PREFIX = ' Stack Trace: ';
    private static final String NULL_REQUEST_MESSAGE = 'Http instance or request is null.';


    // HTTP instance and request
    public Http httpInstance { get; private set; }
    public HttpRequest request { get; private set; }

    // Response type and HTTP callout response instance
    public Type responseType { get; private set; }
    public HttpCalloutResponse httpResponseInstance { get; private set; }

    // Inner class representing the HTTP callout response
    public class HttpCalloutResponse {
        public boolean isSuccess { get; private set; }
        public HttpResponse response { get; private set; }
        public Object parsedResponse { get; private set; }
        public Exception calloutException { get; private set; }
    }

    // Constructor
    public HttpCalloutBuilder() {
        httpInstance = new Http();
        request = new HttpRequest();
        httpResponseInstance = new HttpCalloutResponse();
    }

    // Setters for various request parameters
    public HttpCalloutBuilder setEndpoint(String endpoint) {
        request.setEndpoint(endpoint);
        return this;
    }

    public HttpCalloutBuilder setBody(String body) {
        request.setBody(body);
        return this;
    }

    public HttpCalloutBuilder setBody(Type bodyType, Object body) {
        request.setBody(JSON.serialize(body));
        return this;
    }

    public HttpCalloutBuilder setTimeout(Integer timeout) {
        request.setTimeout(timeout);
        return this;
    }

    public HttpCalloutBuilder setHeader(String key, String value) {
        request.setHeader(key, value);
        return this;
    }

    public HttpCalloutBuilder setMethod(String method) {
        request.setMethod(method);
        return this;
    }

    public HttpCalloutBuilder setResponseType(Type responseType) {
        this.responseType = responseType;
        return this;
    }

    // Send the HTTP request and handle the response
    public HttpCalloutResponse send() {
        //Todo: Add Method to Validate Request
        try {
            httpResponseInstance.response = httpInstance.send(request);

            if (httpResponseInstance.response.getStatusCode() >= 200 && httpResponseInstance.response.getStatusCode() < 300) {
                handleSuccess();
            } else {
                handleException(new CalloutException(NOT_200_RESPONSE));
            }

            return httpResponseInstance;
        } catch (Exception ex) {
            return handleException(new CalloutException(HTTP_CALL_FAILED_MESSAGE + ex.getMessage() + STACK_TRACE_PREFIX + ex.getStackTraceString()));
        }
    }

    // Handle successful response 
    private void handleSuccess() {
        if (responseType != null) {
            parseResponse(responseType);
        }
        httpResponseInstance.isSuccess = true;
    }

    
    //Handles an exception that occurred during the HTTP callout.
    private HttpCalloutResponse handleException(Exception ex) {
        httpResponseInstance.isSuccess = false;
        httpResponseInstance.calloutException = ex;
        return httpResponseInstance;
    }

    
    // Parses the HTTP response body into the specified response type.
    private HttpCalloutResponse parseResponse(Type responseType) {
        try {
            httpResponseInstance.parsedResponse = (responseType != null) ? JSON.deserialize(httpResponseInstance.response.getBody(), responseType) : null;
        } catch (Exception ex) {
            return handleException(new UnableToParseException(ex));
        }
        return httpResponseInstance;
    }
}