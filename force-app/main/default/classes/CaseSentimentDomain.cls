public with sharing class CaseSentimentDomain {

    @InvocableMethod(label='Analyze Sentiment on Cases'
                     description='Calls sentiment API and updates fields')

    public static void analyze(List<CaseWrapper> requestList) {
        List<Case> casesToUpdate = new List<Case>();

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
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    // Wrapper for invocable method
    public class CaseWrapper {
        @InvocableVariable(required=true)
        public Case record;
    }
}
