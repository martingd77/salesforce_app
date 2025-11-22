@IsTest
private class CaseSentimentDomainTest {

    // 1) TEST - Successful sentiment classification
    @IsTest
    static void testAnalyzeSuccess() {
        String successJson = '{"sentiment": "positive", "score": 0.92}';

        // Set mock response
        Test.setMock(HttpCalloutMock.class,
                new SentimentServiceMock(200, successJson)
        );

        // Create test Case
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Latest_Client_Message__c = 'Great service!'
        );
        insert c;

        // Wrap request
        CaseSentimentDomain.CaseWrapper wrap = new CaseSentimentDomain.CaseWrapper();
        wrap.record = c;

        Test.startTest();
        CaseSentimentDomain.analyze(new List<CaseSentimentDomain.CaseWrapper>{ wrap });
        Test.stopTest();

        // Reload case
        Case updated = [SELECT Sentiment__c, Sentiment_Score__c 
                         FROM Case WHERE Id = :c.Id];

        Assert.areEqual('Positive', updated.Sentiment__c, 'Sentiment must be Positive');
        Assert.areEqual(0.92, updated.Sentiment_Score__c, 'Score must match response');
    }


    // 2) TEST - Error from API (invalid JSON / API error)
    @IsTest
    static void testAnalyze_ErrorResponse() {

        // API returns error layout
        Test.setMock(HttpCalloutMock.class,
            new SentimentServiceMock(500, '{"error": "boom"}')
        );

        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Latest_Client_Message__c = 'Bad text'
        );
        insert c;

        CaseSentimentDomain.CaseWrapper wrap = new CaseSentimentDomain.CaseWrapper();
        wrap.record = c;

        Test.startTest();

        // If analyzeText() throws → we expect exception
        Boolean thrown = false;
        try {
            CaseSentimentDomain.analyze(new List<CaseSentimentDomain.CaseWrapper>{ wrap });
        } catch (Exception e) {
            thrown = true;
        }

        Test.stopTest();

        Assert.isTrue(thrown, 'An exception should be thrown for invalid API response');
    }
}
