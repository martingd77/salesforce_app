public with sharing class CaseTriggerHandler {

    public static void run(List<Case> newList, Map<Id, Case> oldMap) {

        // solo after update
        if (!Trigger.isAfter || !Trigger.isUpdate) {
            return;
        }

        List<Case> toProcess = new List<Case>();

        for (Case c : newList) {
            Case oldRecord = oldMap.get(c.Id);

            Boolean changedMessage = 
                c.Latest_Client_Message__c != oldRecord.Latest_Client_Message__c;

            if (changedMessage && String.isNotBlank(c.Latest_Client_Message__c)) {
                toProcess.add(c);
            }
        }

        if (!toProcess.isEmpty()) {
            System.enqueueJob(new SentimentJob(toProcess));
        }
    }
}
