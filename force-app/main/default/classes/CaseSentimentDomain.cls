public with sharing class CaseSentimentDomain {

    @InvocableMethod(label='Analyze Sentiment on Cases'
                     description='Calls sentiment API and updates fields')

    public static void analyze(List<CaseWrapper> requestList) {
        List<Case> casesToUpdate = new List<Case>();
        List<Task> tasksToCreate = new List<Task>();

        for (CaseWrapper wrapper : requestList) {
            Case c = wrapper.record;

            if (String.isBlank(c.Latest_Client_Message__c)) {
                continue;    
            }
            
            // Call API
            SentimentDTO.SentimentResponse result =
                SentimentService.callAPI(c.Latest_Client_Message__c);

            // Set fields
            c.Sentiment__c = result.sentiment;
            c.Sentiment_Score__c = result.score;

            casesToUpdate.add(c);

            // Create Task if sentiment is negative
            if (result.sentiment != null && result.sentiment.equalsIgnoreCase('Negative')) {
                Task t = new Task(
                    Subject = 'Revisar sentimiento negativo del cliente',
                    Description = 'El sentimiento del mensaje del cliente es negativo (Score: ' + result.score + '). Requiere atención inmediata.',
                    WhatId = c.Id,
                    Status = 'Not Started',
                    Priority = 'High'
                );
                tasksToCreate.add(t);
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }

        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }

    // Wrapper for invocable method
    public class CaseWrapper {
        @InvocableVariable(required=true)
        public Case record;
    }
}
