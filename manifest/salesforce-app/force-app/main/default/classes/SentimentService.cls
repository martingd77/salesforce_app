public with sharing class SentimentService {
    private static final String ENDPOINT = 'callout:SentimentAPI';

    public static SentimentDTO.SentimentResponse analyzeText(String text){
        if (String.isBlank(text)) {
            throw new SentimentException('Text cannot be empty');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Body DTO
        SentimentDTO.SentimentRequest body = new SentimentDTO.SentimentRequest(text);
        req.setBody(JSON.serialize(body));

         // Send request
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            throw new SentimentException(
                'API error. Status: ' + res.getStatusCode() + ' - Body: ' + res.getBody()
            );
        }

        // Parse JSON
        return (SentimentDTO.SentimentResponse)JSON.deserialize(res.getBody(), SentimentDTO.SentimentResponse.class);
    }

    // Custom exception
    public class SentimentException extends Exception {}

}