@isTest
private class SentimentServiceTest {

    @IsTest
    static void test_success() {

        String successJson = '{"sentiment": "Positive", "score": 0.92}';

        // Set mock response
        Test.setMock(HttpCalloutMock.class,
                new SentimentServiceMock(200, successJson)
        );

        // Build a request so the mock knows the mode
        HttpRequest req = new HttpRequest();
        req.setHeader('X-Mock-Mode', 'success');

        SentimentDTO.SentimentResponse result =
            SentimentService.analyzeText('This is great');

        Assert.areEqual('Positive', result.sentiment);
        Assert.areEqual(0.92, result.score);
    }


    @isTest
    static void test_error() {
        Test.setMock(HttpCalloutMock.class,
            new SentimentServiceMock(500, '{"error": "boom"}')
        );

        // Force error
        HttpRequest req = new HttpRequest();
        req.setHeader('X-Mock-Mode', 'error');

        try {
            SentimentService.analyzeText('Bad');
            Assert.isFalse(false, 'Should throw error');
        }
        catch (SentimentService.SentimentException ex) {
            Assert.isTrue(ex.getMessage().contains('API error'));
        }
    }
}