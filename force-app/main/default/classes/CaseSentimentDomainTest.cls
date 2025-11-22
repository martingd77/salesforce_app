@IsTest
private class CaseSentimentDomainTest {

    // 1) TEST - Successful sentiment classification
    @IsTest
    static void testAnalyzeSuccess() {
        String successJson = '{"sentiment": "Positive", "score": 0.92}';

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


    // 3) TEST - Task creation for negative sentiment
    @IsTest
    static void testAnalyze_NegativeSentimentCreatesTask() {
        String negativeJson = '{"sentiment": "Negative", "score": 0.15}';

        // Set mock response
        Test.setMock(HttpCalloutMock.class,
                new SentimentServiceMock(200, negativeJson)
        );

        // Create test Case
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Latest_Client_Message__c = 'Terrible service!'
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

        Assert.areEqual('Negative', updated.Sentiment__c, 'Sentiment must be Negative');
        Assert.areEqual(0.15, updated.Sentiment_Score__c, 'Score must match response');

        // Verify Task was created for negative sentiment
        List<Task> tasks = [SELECT Id, Subject, Description, WhatId, Status, Priority 
                           FROM Task WHERE WhatId = :c.Id];
        Assert.areEqual(1, tasks.size(), 'A Task should be created for negative sentiment');
        Assert.areEqual('Revisar sentimiento negativo del cliente', tasks[0].Subject);
        Assert.areEqual('High', tasks[0].Priority);
        Assert.areEqual('Not Started', tasks[0].Status);
        Assert.isTrue(tasks[0].Description.contains('negativo'), 'Description should mention negative sentiment');
    }


    // 4) TEST - Normalization of sentiment value (lowercase from API)
    @IsTest
    static void testAnalyze_NormalizesSentimentValue() {
        // API returns lowercase sentiment
        String json = '{"sentiment": "negative", "score": 0.10}';

        Test.setMock(HttpCalloutMock.class,
                new SentimentServiceMock(200, json)
        );

        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Latest_Client_Message__c = 'Awful experience!'
        );
        insert c;

        CaseSentimentDomain.CaseWrapper wrap = new CaseSentimentDomain.CaseWrapper();
        wrap.record = c;

        Test.startTest();
        CaseSentimentDomain.analyze(new List<CaseSentimentDomain.CaseWrapper>{ wrap });
        Test.stopTest();

        // Verify sentiment is normalized to "Negative" (capitalized)
        Case updated = [SELECT Sentiment__c, Sentiment_Score__c 
                         FROM Case WHERE Id = :c.Id];
        Assert.areEqual('Negative', updated.Sentiment__c, 'Sentiment should be normalized to Negative');
        
        // Verify Task was created (should work even with lowercase input)
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :c.Id];
        Assert.areEqual(1, tasks.size(), 'Task should be created even if API returns lowercase "negative"');
    }
}
