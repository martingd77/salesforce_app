public with sharing class SentimentJob implements Queueable, Database.AllowsCallouts {

    private List<Case> casesToProcess;

    public SentimentJob(List<Case> casesToProcess) {
        this.casesToProcess = casesToProcess;
    }

    public void execute(QueueableContext qc) {

        List<Case> updates = new List<Case>();
        List<Task> tasksToCreate = new List<Task>();

        for (Case c : casesToProcess) {
            try {
                SentimentDTO.SentimentResponse resp =
                    SentimentService.callAPI(c.Latest_Client_Message__c);

                Case updatedCase = new Case(
                    Id = c.Id,
                    Sentiment__c = resp.sentiment,
                    Sentiment_Score__c = resp.score
                );

                updates.add(updatedCase);

                // Create Task if sentiment is negative
                if (resp.sentiment != null && resp.sentiment.equalsIgnoreCase('Negative')) {
                    Task t = new Task(
                        Subject = 'Revisar sentimiento negativo del cliente',
                        Description = 'El sentimiento del mensaje del cliente es negativo (Score: ' + resp.score + '). Requiere atención inmediata.',
                        WhatId = c.Id,
                        Status = 'Not Started',
                        Priority = 'High'
                    );
                    tasksToCreate.add(t);
                }

            } catch (Exception ex) {
                System.debug('Error in sentiment job: ' + ex.getMessage());
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }

        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }
}
