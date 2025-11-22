@IsTest
global class SentimentServiceMock implements HttpCalloutMock {

    private Integer code;
    private String body;

    // Constructor
    public SentimentServiceMock(Integer statusCode, String responseBody) {
        this.code = statusCode;
        this.body = responseBody;
    }

    // Called by Http.send(...) automatically
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(code);
        res.setBody(body);
        return res;
    }
}
