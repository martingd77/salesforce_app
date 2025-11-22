public with sharing class SentimentJob implements Queueable, Database.AllowsCallouts {

    private List<Case> casesToProcess;

    public SentimentJob(List<Case> casesToProcess) {
        this.casesToProcess = casesToProcess;
    }

    public void execute(QueueableContext qc) {

        List<Case> updates = new List<Case>();

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

            } catch (Exception ex) {
                System.debug('Error in sentiment job: ' + ex.getMessage());
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }
}
