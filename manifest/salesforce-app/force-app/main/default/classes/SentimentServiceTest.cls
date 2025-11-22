@isTest
private class SentimentServiceTest {

    @isTest
    static void test_callAPI_success() {
        String successJson = '{"sentiment": "Positive", "score": 0.92}';

        Test.setMock(HttpCalloutMock.class,
            new SentimentServiceMock(200, successJson)
        );

        SentimentDTO.SentimentResponse result =
            SentimentService.callAPI('This is great');

        System.assertEquals('Positive', result.sentiment);
        System.debug(result);
        System.assertEquals(0.92, result.score);
    }


    @isTest
    static void test_callAPI_error() {

        Test.setMock(HttpCalloutMock.class,
            new SentimentServiceMock(500, '{"error": "boom"}')
        );

        try {
            SentimentService.callAPI('Bad text');
            System.assert(false, 'Expected an exception');
        }
        catch (Exception ex) {
            System.assert(
                ex.getMessage().contains('API error') ||
                ex.getMessage().contains('500'),
                'Error message should mention API failure'
            );
        }
    }


    @isTest
    static void test_queueable_updates_case() {

        String json = '{"sentiment": "Negative", "score": 0.13}';

        Test.setMock(HttpCalloutMock.class,
            new SentimentServiceMock(200, json)
        );

        // Crear Case
        Case c = new Case(
            Subject = 'Test',
            Status = 'New',
            Latest_Client_Message__c = 'Horrible service'
        );
        insert c;

        // Ejecutar queueable directamente
        SentimentJob job = new SentimentJob(new List<Case>{ c });

        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();

        // Refetch
        Case updatedCase = [SELECT Sentiment__c, Sentiment_Score__c FROM Case WHERE Id = :c.Id];

        System.assertEquals('Negative', updatedCase.Sentiment__c);
        System.assertEquals(0.13, updatedCase.Sentiment_Score__c);
    }


    @isTest
    static void test_trigger_handler_end_to_end() {

        String json = '{"sentiment": "Neutral", "score": 0.50}';

        Test.setMock(HttpCalloutMock.class,
            new SentimentServiceMock(200, json)
        );

        // Insert Case sin mensaje → el trigger NO se dispara.
        Case c = new Case(
            Subject = 'Demo',
            Status = 'New'
        );
        insert c;

        // Update con mensaje → trigger ejecuta Queueable
        Test.startTest();
        c.Latest_Client_Message__c = 'Ok, thanks.';
        update c;
        Test.stopTest(); // Ejecuta el queueable del trigger

        Case updated = [
            SELECT Sentiment__c, Sentiment_Score__c
            FROM Case
            WHERE Id = :c.Id
        ];

        System.assertEquals('Neutral', updated.Sentiment__c);
        System.assertEquals(0.50, updated.Sentiment_Score__c);
    }
}
