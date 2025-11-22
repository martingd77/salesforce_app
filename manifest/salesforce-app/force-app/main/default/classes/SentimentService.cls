public with sharing class SentimentService {

    private static final String ENDPOINT = 'callout:SentimentAPI';

    public static SentimentDTO.SentimentResponse callAPI(String text) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        req.setBody(JSON.serialize(
            new Map<String, String>{ 'text' => text }
        ));

        Http http = new Http();
        HttpResponse res = http.send(req);

        // Check for HTTP errors
        if (res.getStatusCode() != 200) {
            throw new SentimentException(
                'API error: HTTP ' + res.getStatusCode() + ' - ' + res.getBody()
            );
        }

        return (SentimentDTO.SentimentResponse)
            JSON.deserialize(res.getBody(), SentimentDTO.SentimentResponse.class);
    }

    // Custom exception
    public class SentimentException extends Exception {}

}